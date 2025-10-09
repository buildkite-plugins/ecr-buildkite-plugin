#!/bin/bash

# Configure Docker to use ECR credential helper for specific registries
function setup_ecr_credential_helper() {
  local docker_config_dir="${DOCKER_CONFIG:-$HOME/.docker}"
  local docker_config_file="$docker_config_dir/config.json"
  
  # Create docker config directory if it doesn't exist
  if [[ ! -d "$docker_config_dir" ]]; then
    mkdir -p "$docker_config_dir"
  fi
  
  # Initialize with empty object if file doesn't exist
  if [[ ! -f "$docker_config_file" ]]; then
    echo '{}' > "$docker_config_file"
  fi
  
  # Read current account IDs to determine which registries to configure
  local account_ids=()
  while IFS='' read -r line; do account_ids+=("$line"); done < <(plugin_read_list ACCOUNT_IDS | tr "," "\n")
  
  # If no account IDs specified, try to get current account
  if [[ ${#account_ids[@]} -eq 0 || -z "${account_ids[*]}" ]]; then
    if command -v aws >/dev/null 2>&1; then
      local current_account
      current_account="$(aws sts get-caller-identity --query Account --output text 2>/dev/null || true)"
      if [[ -n "$current_account" ]]; then
        account_ids=("$current_account")
      fi
    fi
  fi
  
  # Configure credential helper for each registry
  local tmp_file
  tmp_file="$(mktemp)"
  
  if ! jq . "$docker_config_file" > /dev/null 2>&1; then
    echo "Error: Invalid JSON in Docker config file: $docker_config_file" >&2
    rm -f "$tmp_file"
    return 1
  fi
  
  # Start with existing config and ensure credHelpers and auths objects exist
  jq '.credHelpers = (.credHelpers // {}) | .auths = (.auths // {})' "$docker_config_file" > "$tmp_file"

  # Configure credential helper for each ECR registry
  for account_id in "${account_ids[@]}"; do
    if [[ -n "$account_id" ]]; then
      if [[ "$account_id" == "public.ecr.aws" ]]; then
        # Configure for ECR Public
        jq --arg registry "$account_id" '.credHelpers[$registry] = "ecr-login" | .auths[$registry] = {}' "$tmp_file" > "$tmp_file.new" && mv "$tmp_file.new" "$tmp_file"
        echo "Configured ECR credential helper for $account_id"
      else
        # Configure for private ECR registries
        local region="${BUILDKITE_PLUGIN_ECR_REGISTRY_REGION:-${BUILDKITE_PLUGIN_ECR_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}}"
        local ecr_registry_url

        if [[ ${region:0:3} == "cn-" ]]; then
          ecr_registry_url="$account_id.dkr.ecr.$region.amazonaws.com.cn"
        else
          ecr_registry_url="$account_id.dkr.ecr.$region.amazonaws.com"
        fi

        jq --arg registry "$ecr_registry_url" '.credHelpers[$registry] = "ecr-login" | .auths[$registry] = {}' "$tmp_file" > "$tmp_file.new" && mv "$tmp_file.new" "$tmp_file"
        echo "Configured ECR credential helper for $ecr_registry_url"
      fi
    fi
  done
  
  # Atomic move to prevent race conditions with other processes
  if mv "$tmp_file" "$docker_config_file"; then
    echo "ECR credential helper configured successfully"
    return 0
  else
    echo "Error: Failed to update Docker config file: $docker_config_file" >&2
    rm -f "$tmp_file"
    return 1
  fi
}

# Login using ECR credential helper by configuring Docker
function login_using_ecr_credential_helper() {
  echo "~~~ Configuring ECR credential helper :ecr: :docker:"
  
  if ! command -v docker-credential-ecr-login >/dev/null 2>&1; then
    echo "Error: docker-credential-ecr-login not found in PATH" >&2
    echo "Please install the Amazon ECR credential helper: https://github.com/awslabs/amazon-ecr-credential-helper" >&2
    return 1
  fi
  
  # Check if jq is available for JSON manipulation
  if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required for ECR credential helper configuration but not found in PATH" >&2
    return 1
  fi

  # Setup the credential helper configuration
  if setup_ecr_credential_helper; then
    echo "ECR credential helper is now active for Docker operations"
    return 0
  else
    echo "Failed to configure ECR credential helper" >&2
    return 1
  fi
}
