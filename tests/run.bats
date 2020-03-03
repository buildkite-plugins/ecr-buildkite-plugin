#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031
# (modifying vars in subshells is expected)

load '/usr/local/lib/bats/load.bash'

# export AWS_STUB_DEBUG=/dev/tty

@test "ECR login (v2.0.0; after get-login was removed)" {
  skip "awscli v2+ not yet supported"
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_NO_INCLUDE_EMAIL=true

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "ecr get-login --no-include-email : echo fail && false"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"

  unstub aws
  unstub docker
}

@test "ECR login (v1.17.10; after get-login-password was added, before get-login was removed)" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_NO_INCLUDE_EMAIL=true

  stub aws \
    "--version : echo aws-cli/1.17.9 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "ecr get-login --no-include-email : echo docker login -u AWS -p 1234 https://1234.dkr.ecr.us-east-1.amazonaws.com"

  stub docker \
    "login -u AWS -p 1234 https://1234.dkr.ecr.us-east-1.amazonaws.com : echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"

  unstub aws
  unstub docker
}

@test "aws ecr get-login (v1.17.9; before get-login-password was added)" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_NO_INCLUDE_EMAIL=true

  stub aws \
    "--version : echo aws-cli/1.17.9 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "ecr get-login --no-include-email : echo docker login -u AWS -p 1234 https://1234.dkr.ecr.us-east-1.amazonaws.com"

  stub docker \
    "login -u AWS -p 1234 https://1234.dkr.ecr.us-east-1.amazonaws.com : echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"

  unstub aws
  unstub docker
}

@test "aws ecr get-login (without --no-include-email)" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_NO_INCLUDE_EMAIL=false

  stub aws \
    "--version : echo aws-cli/1.17.9 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "ecr get-login : echo docker login -u AWS -p 1234 https://1234.dkr.ecr.us-east-1.amazonaws.com"

  stub docker \
    "login -u AWS -p 1234 https://1234.dkr.ecr.us-east-1.amazonaws.com : echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"

  unstub aws
  unstub docker
}

@test "aws ecr get-login with Account IDS" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS_0=1111
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS_1=2222
  export BUILDKITE_PLUGIN_ECR_NO_INCLUDE_EMAIL=true

  stub aws \
    "--version : echo aws-cli/1.17.9 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "ecr get-login --no-include-email --registry-ids 1111 2222 : echo echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"

  unstub aws
}

@test "aws ecr get-login with Comma-delimited Account IDS (older aws-cli)" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS="1111,2222,3333"

  stub aws \
    "--version : echo aws-cli/1.11.40 Python/2.7.10 Darwin/16.6.0 botocore/1.5.80" \
    "--version : echo aws-cli/1.11.40 Python/2.7.10 Darwin/16.6.0 botocore/1.5.80" \
    "ecr get-login --registry-ids 1111 2222 3333 : echo echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"

  unstub aws
}

@test "aws ecr get-login with Comma-delimited Account IDS (newer aws-cli)" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS="1111,2222,3333"

  stub aws \
    "--version : echo aws-cli/1.11.117 Python/2.7.10 Darwin/16.6.0 botocore/1.5.80" \
    "--version : echo aws-cli/1.11.117 Python/2.7.10 Darwin/16.6.0 botocore/1.5.80" \
    "ecr get-login --no-include-email --registry-ids 1111 2222 3333 : echo echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"

  unstub aws
}

@test "aws ecr get-login with region specified" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_NO_INCLUDE_EMAIL=true
  export BUILDKITE_PLUGIN_ECR_REGISTRY_REGION=ap-southeast-2

  stub aws \
    "--version : echo aws-cli/1.17.9 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "ecr get-login --no-include-email --region ap-southeast-2 : echo docker login -u AWS -p 1234 https://1234.dkr.ecr.ap-southeast-2.amazonaws.com"

  stub docker \
    "login -u AWS -p 1234 https://1234.dkr.ecr.ap-southeast-2.amazonaws.com : echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"

  unstub aws
  unstub docker
}

@test "aws ecr get-login with region and registry id's" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_NO_INCLUDE_EMAIL=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS="1111,2222,3333"
  export BUILDKITE_PLUGIN_ECR_REGISTRY_REGION=ap-southeast-2

  stub aws \
    "--version : echo aws-cli/1.17.9 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "ecr get-login --no-include-email --region ap-southeast-2 --registry-ids 1111 2222 3333 : echo docker login -u AWS -p 1234 https://1234.dkr.ecr.ap-southeast-2.amazonaws.com"

  stub docker \
    "login -u AWS -p 1234 https://1234.dkr.ecr.ap-southeast-2.amazonaws.com : echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"

  unstub aws
  unstub docker
}

@test "aws ecr get-login with error, and then retry until success" {
  [[ -z $SKIP_SLOW ]] || skip "skipping slow test"
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_NO_INCLUDE_EMAIL=true
  export BUILDKITE_PLUGIN_ECR_RETRIES=1

  stub aws \
    "--version : echo aws-cli/1.17.9 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "ecr get-login --no-include-email : exit 1" \
    "ecr get-login --no-include-email : echo echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "Login failed on attempt 1 of 2. Trying again in 1 seconds.."
  assert_output --partial "logging in to docker"

  unstub aws
}

@test "aws ecr get-login with error, and then retry until failure" {
  [[ -z $SKIP_SLOW ]] || skip "skipping slow test"
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_NO_INCLUDE_EMAIL=true
  export BUILDKITE_PLUGIN_ECR_RETRIES=1

  stub aws \
    "--version : echo aws-cli/1.17.9 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "ecr get-login --no-include-email : exit 1" \
    "ecr get-login --no-include-email : exit 1"

  run "$PWD/hooks/environment"

  assert_failure
  assert_output --partial "Login failed on attempt 1 of 2. Trying again in 1 seconds..."
  assert_output --partial "Login failed after 2 attempts"

  unstub aws
}

@test "aws ecr get-login doesn't disclose credentials" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_NO_INCLUDE_EMAIL=true

  stub aws \
    "--version : echo aws-cli/1.17.9 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "ecr get-login --no-include-email : echo docker login -u AWS -p supersecret https://1234.dkr.ecr.us-east-1.amazonaws.com"

  stub docker \
    "login -u AWS -p supersecret https://1234.dkr.ecr.us-east-1.amazonaws.com : echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  refute_output --partial "supersecret"

  unstub aws
  unstub docker
}
