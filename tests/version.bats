#!/usr/bin/env bats

load "${BATS_PLUGIN_PATH}/load.bash"

# Disable login before sourcing to prevent execution during test setup
export BUILDKITE_PLUGIN_ECR_LOGIN=false

load "$PWD/hooks/environment"

@test "version_a_gte_b: basic: major less; false" {
  run version_a_gte_b "1.3.3" "3.2.1"
  assert_failure
}
@test "version_a_gte_b: basic: major more; true" {
  run version_a_gte_b "3.2.1" "1.3.2"
  assert_success
}
@test "version_a_gte_b: basic: major same, minor less; false" {
  run version_a_gte_b "3.2.1" "3.3.0"
  assert_failure
}
@test "version_a_gte_b: basic: major same, minor more; true" {
  run version_a_gte_b "3.2.1" "3.1.2"
  assert_success
}
@test "version_a_gte_b: basic: major same, minor same, patch same; true" {
  run version_a_gte_b "1.1.1" "1.1.1"
  assert_success
}
@test "version_a_gte_b: basic: major same, minor same, patch more; true" {
  run version_a_gte_b "1.1.2" "1.1.1"
  assert_success
}
@test "version_a_gte_b: basic: major same, minor same, patch less; false" {
  run version_a_gte_b "1.1.1" "1.1.2"
  assert_failure
}
@test "version_a_gte_b: specific: 1.11.40 >= 1.11.91; false" {
  run version_a_gte_b "1.11.40" "1.11.91"
  assert_failure
}
@test "version_a_gte_b: specific: 2.0.2 >= 1.11.91; true" {
  run version_a_gte_b "2.0.2" "1.11.91"
  assert_success
}
@test "version_a_gte_b: specific: 2.0.2 >= 2.0.0; true" {
  run version_a_gte_b "2.0.2" "2.0.0"
  assert_success
}

@test "aws_version_ge: standard format aws-cli/2.9.0" {
  aws() { echo "aws-cli/2.9.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3"; }
  export -f aws
  run aws_version_ge "2.8.0"
  assert_success
  unset -f aws
}

@test "aws_version_ge: workspace format aws-cli/workspace/2.9.0" {
  aws() { echo "aws-cli/workspace/2.9.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3"; }
  export -f aws
  run aws_version_ge "2.8.0"
  assert_success
  unset -f aws
}

@test "aws_version_ge: complex path aws-cli/workspace/build/2.9.0" {
  aws() { echo "aws-cli/workspace/build/2.9.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3"; }
  export -f aws
  run aws_version_ge "2.8.0"
  assert_success
  unset -f aws
}

@test "aws_version_ge: version check fails when current < wanted" {
  aws() { echo "aws-cli/workspace/1.18.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3"; }
  export -f aws
  run aws_version_ge "2.0.0"
  assert_failure
  unset -f aws
}

@test "aws_version_ge: handles multiple semver patterns correctly" {
  aws() { echo "aws-cli/2.27.50 Python/3.13.5 Darwin/25.0.0 source/arm64"; }
  export -f aws
  run aws_version_ge "2.20.0"
  assert_success
  unset -f aws
}

@test "aws_version_ge: fails when AWS CLI is not installed" {
  export PATH="/bin:/usr/bin"
  run aws_version_ge "1.0.0"
  assert_failure
  assert_output --partial "Error: AWS CLI is not installed or not in PATH"
}
