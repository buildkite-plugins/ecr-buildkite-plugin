#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031
# (modifying vars in subshells is expected)

load '/usr/local/lib/bats/load.bash'

# export AWS_STUB_DEBUG=/dev/tty

@test "ECR login; configured account ID, configured region" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS=321321321321
  export BUILDKITE_PLUGIN_ECR_REGION=ap-southeast-2

  stub aws \
    "--region ap-southeast-2 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 321321321321.dkr.ecr.ap-southeast-2.amazonaws.com : cat > /tmp/password-stdin ; echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "~~~ Authenticating with AWS ECR :ecr: :docker:"
  assert_output --partial "^^^ Authenticating with AWS ECR in ap-southeast-2 for 321321321321 :ecr: :docker:"
  assert_output --partial "logging in to docker"
  [[ $(cat /tmp/password-stdin) == "hunter2" ]]

  refute_output --partial "hunter2"

  unstub aws
  unstub docker
}

@test "ECR login; configured account ID, configured legacy registry-region" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS=321321321321
  export BUILDKITE_PLUGIN_ECR_REGISTRY_REGION=ap-southeast-2

  stub aws \
    "--region ap-southeast-2 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 321321321321.dkr.ecr.ap-southeast-2.amazonaws.com : cat > /tmp/password-stdin ; echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"
  [[ $(cat /tmp/password-stdin) == "hunter2" ]]

  unstub aws
  unstub docker
}
@test "ECR login; configured account ID, AWS_DEFAULT_REGION set" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS=421321321321
  export AWS_DEFAULT_REGION=us-west-2

  stub aws \
    "--region us-west-2 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 421321321321.dkr.ecr.us-west-2.amazonaws.com : cat > /tmp/password-stdin ; echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"
  [[ $(cat /tmp/password-stdin) == "hunter2" ]]

  unstub aws
  unstub docker
}
@test "ECR login; configured account ID, no region specified defaults to us-east-1" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS=421321321321

  stub aws \
    "--region us-east-1 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 421321321321.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin ; echo logging in to docker"


  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "AWS region should be specified"
  assert_output --partial "Defaulting to us-east-1"
  assert_output --partial "logging in to docker"

  unstub aws
  unstub docker
}
@test "ECR login; multiple account IDs" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS_0=111111111111
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS_1=222222222222
  export BUILDKITE_PLUGIN_ECR_REGION=us-east-1

  stub aws \
    "--region us-east-1 ecr get-login-password : echo sameforeachaccount"

  stub docker \
    "login --username AWS --password-stdin 111111111111.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin-0 ; echo logging in to docker" \
    "login --username AWS --password-stdin 222222222222.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin-1 ; echo logging in to docker"


  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"
  [[ $(cat /tmp/password-stdin-0) == "sameforeachaccount" ]]
  [[ $(cat /tmp/password-stdin-1) == "sameforeachaccount" ]]

  unstub aws
  unstub docker
}
@test "ECR login; multiple comma-separated account IDs" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS=333333333333,444444444444
  export BUILDKITE_PLUGIN_ECR_REGION=us-east-1

  stub aws \
    "--region us-east-1 ecr get-login-password : echo sameforeachaccount"

  stub docker \
    "login --username AWS --password-stdin 333333333333.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin-0 ; echo logging in to docker" \
    "login --username AWS --password-stdin 444444444444.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin-1 ; echo logging in to docker"


  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"
  [[ $(cat /tmp/password-stdin-0) == "sameforeachaccount" ]]
  [[ $(cat /tmp/password-stdin-1) == "sameforeachaccount" ]]

  unstub aws
  unstub docker
}
@test "ECR login; discovered account ID" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export AWS_DEFAULT_REGION=us-east-1

  stub aws \
    "sts get-caller-identity --query Account --output text : echo 888888888888" \
    "--region us-east-1 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 888888888888.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin ; echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"
  [[ $(cat /tmp/password-stdin) == "hunter2" ]]

  unstub aws
  unstub docker
}

@test "ECR login; discovered account ID, with error, and then retry until success" {
  [[ -z $SKIP_SLOW ]] || skip "skipping slow test"
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_RETRIES=1
  export AWS_DEFAULT_REGION=us-east-1

  stub aws \
    "sts get-caller-identity --query Account --output text : echo 888888888888" \
    "--region us-east-1 ecr get-login-password : exit 1" \
    "--region us-east-1 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 888888888888.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin ; echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "Login failed on attempt 1 of 2. Trying again in 1 seconds.."
  assert_output --partial "logging in to docker"
  [[ $(cat /tmp/password-stdin) == "hunter2" ]]

  unstub aws
  unstub docker
}

@test "ECR login; discovered account ID, with error, and then retry until failure" {
  [[ -z $SKIP_SLOW ]] || skip "skipping slow test"
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_RETRIES=1
  export AWS_DEFAULT_REGION=us-east-1

  stub aws \
    "sts get-caller-identity --query Account --output text : echo 888888888888" \
    "--region us-east-1 ecr get-login-password : exit 1" \
    "--region us-east-1 ecr get-login-password : exit 1"

  run "$PWD/hooks/environment"

  assert_failure
  assert_output --partial "Login failed on attempt 1 of 2. Trying again in 1 seconds.."
  assert_output --partial "Login failed after 2 attempts"

  unstub aws
}
