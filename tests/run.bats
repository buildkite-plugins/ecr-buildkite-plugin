#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031
# (modifying vars in subshells is expected)

load "${BATS_PLUGIN_PATH}/load.bash"

# export AWS_STUB_DEBUG=/dev/tty
# export DOCKER_STUB_DEBUG=/dev/tty

@test "ECR login; configured account ID, configured region, configured profile" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS=321321321321
  export BUILDKITE_PLUGIN_ECR_REGION=ap-southeast-2
  export BUILDKITE_PLUGIN_ECR_PROFILE=ecr

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "--region ap-southeast-2 --profile ecr ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 321321321321.dkr.ecr.ap-southeast-2.amazonaws.com : cat > /tmp/password-stdin ; echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "~~~ Authenticating with AWS ECR :ecr: :docker:"
  assert_output --partial "^^^ Authenticating with AWS ECR in ap-southeast-2 for 321321321321 :ecr: :docker:"
  assert_output --partial "logging in to docker"
  assert_equal "hunter2" "$(cat /tmp/password-stdin)"

  unstub aws
  unstub docker
  rm /tmp/password-stdin
}

@test "ECR login; configured account ID, configured region" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS=321321321321
  export BUILDKITE_PLUGIN_ECR_REGION=ap-southeast-2

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "--region ap-southeast-2 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 321321321321.dkr.ecr.ap-southeast-2.amazonaws.com : cat > /tmp/password-stdin ; echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "~~~ Authenticating with AWS ECR :ecr: :docker:"
  assert_output --partial "^^^ Authenticating with AWS ECR in ap-southeast-2 for 321321321321 :ecr: :docker:"
  assert_output --partial "logging in to docker"
  assert_equal "hunter2" "$(cat /tmp/password-stdin)"

  unstub aws
  unstub docker
  rm /tmp/password-stdin
}

@test "ECR login; configured account ID, configured legacy registry-region" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS=321321321321
  export BUILDKITE_PLUGIN_ECR_REGISTRY_REGION=ap-southeast-2

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "--region ap-southeast-2 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 321321321321.dkr.ecr.ap-southeast-2.amazonaws.com : cat > /tmp/password-stdin ; echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"
  assert_equal "hunter2" "$(cat /tmp/password-stdin)"

  unstub aws
  unstub docker
  rm /tmp/password-stdin
}

@test "ECR login; configured account ID, AWS_DEFAULT_REGION set" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS=421321321321
  export AWS_DEFAULT_REGION=us-west-2

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "--region us-west-2 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 421321321321.dkr.ecr.us-west-2.amazonaws.com : cat > /tmp/password-stdin ; echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"
  assert_equal "hunter2" "$(cat /tmp/password-stdin)"

  unstub aws
  unstub docker
  rm /tmp/password-stdin
}

@test "ECR login; configured account ID, no region specified defaults to us-east-1" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS=421321321321

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "--region us-east-1 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 421321321321.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin ; echo logging in to docker"


  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "AWS region should be specified"
  assert_output --partial "Defaulting to us-east-1"
  assert_output --partial "logging in to docker"
  assert_equal "hunter2" "$(cat /tmp/password-stdin)"

  unstub aws
  unstub docker
  rm /tmp/password-stdin
}

@test "ECR login; configured account ID, configured China region, configured profile" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS=321321321321
  export BUILDKITE_PLUGIN_ECR_REGION=cn-north-1
  export BUILDKITE_PLUGIN_ECR_PROFILE=ecr

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "--region cn-north-1 --profile ecr ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 321321321321.dkr.ecr.cn-north-1.amazonaws.com.cn : cat > /tmp/password-stdin ; echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "~~~ Authenticating with AWS ECR :ecr: :docker:"
  assert_output --partial "^^^ Authenticating with AWS ECR in cn-north-1 for 321321321321 :ecr: :docker:"
  assert_output --partial "logging in to docker"
  assert_equal "hunter2" "$(cat /tmp/password-stdin)"

  unstub aws
  unstub docker
  rm /tmp/password-stdin
}

@test "ECR login; configured account ID, configured region" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS=321321321321
  export BUILDKITE_PLUGIN_ECR_REGION=cn-north-1

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "--region cn-north-1 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 321321321321.dkr.ecr.cn-north-1.amazonaws.com.cn : cat > /tmp/password-stdin ; echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "~~~ Authenticating with AWS ECR :ecr: :docker:"
  assert_output --partial "^^^ Authenticating with AWS ECR in cn-north-1 for 321321321321 :ecr: :docker:"
  assert_output --partial "logging in to docker"
  assert_equal "hunter2" "$(cat /tmp/password-stdin)"

  unstub aws
  unstub docker
  rm /tmp/password-stdin
}

@test "ECR login; multiple account IDs" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS_0=111111111111
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS_1=222222222222
  export BUILDKITE_PLUGIN_ECR_REGION=us-east-1

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "--region us-east-1 ecr get-login-password : echo sameforeachaccount"

  stub docker \
    "login --username AWS --password-stdin 111111111111.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin-0 ; echo logging in to docker" \
    "login --username AWS --password-stdin 222222222222.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin-1 ; echo logging in to docker"


  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"
  assert_equal "sameforeachaccount" "$(cat /tmp/password-stdin-0)"
  assert_equal "sameforeachaccount" "$(cat /tmp/password-stdin-1)"

  unstub aws
  unstub docker
  rm /tmp/password-stdin-0
  rm /tmp/password-stdin-1
}

@test "ECR login; multiple comma-separated account IDs" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS=333333333333,444444444444
  export BUILDKITE_PLUGIN_ECR_REGION=us-east-1

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "--region us-east-1 ecr get-login-password : echo sameforeachaccount"

  stub docker \
    "login --username AWS --password-stdin 333333333333.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin-0 ; echo logging in to docker" \
    "login --username AWS --password-stdin 444444444444.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin-1 ; echo logging in to docker"


  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"
  assert_equal "sameforeachaccount" "$(cat /tmp/password-stdin-0)"
  assert_equal "sameforeachaccount" "$(cat /tmp/password-stdin-1)"

  unstub aws
  unstub docker
  rm /tmp/password-stdin-0
  rm /tmp/password-stdin-1
}

@test "ECR login; discovered account ID" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export AWS_DEFAULT_REGION=us-east-1

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "sts get-caller-identity --query Account --output text : echo 888888888888" \
    "--region us-east-1 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 888888888888.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin ; echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"
  assert_equal "hunter2" "$(cat /tmp/password-stdin)"

  unstub aws
  unstub docker
  rm /tmp/password-stdin
}

@test "ECR login; discovered account ID, with error, and then retry until success" {
  [[ -z $SKIP_SLOW ]] || skip "skipping slow test"
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_RETRIES=1
  export AWS_DEFAULT_REGION=us-east-1

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "sts get-caller-identity --query Account --output text : echo 888888888888" \
    "--region us-east-1 ecr get-login-password : exit 1" \
    "--region us-east-1 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 888888888888.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin ; echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "Login failed on attempt 1 of 2. Trying again in 1 seconds.."
  assert_output --partial "logging in to docker"
  assert_equal "hunter2" "$(cat /tmp/password-stdin)"

  unstub aws
  unstub docker
  rm /tmp/password-stdin
}

@test "ECR login; discovered account ID, with error in docker login, and then retry until success" {
  [[ -z $SKIP_SLOW ]] || skip "skipping slow test"
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_RETRIES=1
  export AWS_DEFAULT_REGION=us-east-1

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "sts get-caller-identity --query Account --output text : echo 888888888888" \
    "--region us-east-1 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 888888888888.dkr.ecr.us-east-1.amazonaws.com : exit 1" \
    "login --username AWS --password-stdin 888888888888.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin ; echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "Login failed on attempt 1 of 2. Trying again in 1 seconds.."
  assert_output --partial "logging in to docker"
  assert_equal "hunter2" "$(cat /tmp/password-stdin)"

  unstub aws
  unstub docker
  rm /tmp/password-stdin
}

@test "ECR login; discovered account ID, with error, and then retry until failure" {
  [[ -z $SKIP_SLOW ]] || skip "skipping slow test"
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_RETRIES=1
  export AWS_DEFAULT_REGION=us-east-1

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "sts get-caller-identity --query Account --output text : echo 888888888888" \
    "--region us-east-1 ecr get-login-password : exit 1" \
    "--region us-east-1 ecr get-login-password : exit 1"

  run "$PWD/hooks/environment"

  assert_failure
  assert_output --partial "Login failed on attempt 1 of 2. Trying again in 1 seconds.."
  assert_output --partial "Login failed after 2 attempts"

  unstub aws
}

@test "ECR login; discovered account ID, with error in docker login, and then retry until failure" {
  [[ -z $SKIP_SLOW ]] || skip "skipping slow test"
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_RETRIES=1
  export AWS_DEFAULT_REGION=us-east-1

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "sts get-caller-identity --query Account --output text : echo 888888888888" \
    "--region us-east-1 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 888888888888.dkr.ecr.us-east-1.amazonaws.com : exit 1" \
    "login --username AWS --password-stdin 888888888888.dkr.ecr.us-east-1.amazonaws.com : exit 1"

  run "$PWD/hooks/environment"

  assert_failure
  assert_output --partial "Login failed on attempt 1 of 2. Trying again in 1 seconds.."
  assert_output --partial "Login failed after 2 attempts"

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

@test "ECR login (before aws cli 1.17.10 in which get-login-password was added)" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_NO_INCLUDE_EMAIL=true

  stub aws \
    "--version : echo aws-cli/1.17.9 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "ecr get-login --no-include-email : echo docker login -u AWS -p 1234 https://1234.dkr.ecr.us-east-1.amazonaws.com"

  stub docker \
    "login -u AWS -p 1234 https://1234.dkr.ecr.us-east-1.amazonaws.com : echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "~~~ Authenticating with AWS ECR :ecr: :docker:"
  assert_output --partial "logging in to docker"

  unstub aws
  unstub docker
}

@test "ECR login (before aws cli 1.17.10) (without --no-include-email)" {
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

@test "ECR login (before aws cli 1.17.10) with Account IDS" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS_0=1111
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS_1=2222
  export BUILDKITE_PLUGIN_ECR_NO_INCLUDE_EMAIL=true

  stub aws \
    "--version : echo aws-cli/1.17.9 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "ecr get-login --no-include-email --registry-ids 1111 2222 : echo echo logging in to docker"

  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "~~~ Authenticating with AWS ECR :ecr: :docker:"
  assert_output --partial "^^^ Authenticating with AWS ECR for 1111 2222 :ecr: :docker:"
  assert_output --partial "logging in to docker"

  unstub aws
}

@test "ECR login (before aws cli 1.17.10) with Comma-delimited Account IDS (older aws-cli)" {
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

@test "ECR login (before aws cli 1.17.10) with Comma-delimited Account IDS (newer aws-cli)" {
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

@test "ECR login (before aws cli 1.17.10) with region specified" {
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

@test "ECR login (before aws cli 1.17.10) with region and registry id's" {
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

@test "ECR login (before aws cli 1.17.10) with error, and then retry until success" {
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

@test "ECR login (before aws cli 1.17.10) with error, and then retry until failure" {
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

@test "ECR login (before aws cli 1.17.10) doesn't disclose credentials" {
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

@test "ECR login; public registry even in other regions" {
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_ACCOUNT_IDS=public.ecr.aws
  export AWS_DEFAULT_REGION=us-west-2

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "--region us-east-1 ecr-public get-login-password : echo public"

  stub docker \
    "login --username AWS --password-stdin public.ecr.aws : cat > /tmp/password-stdin ; echo logging in to docker"


  run "$PWD/hooks/environment"

  assert_success
  assert_output --partial "logging in to docker"
  assert_equal "public" "$(cat /tmp/password-stdin)"

  unstub aws
  unstub docker
  rm /tmp/password-stdin
}

@test "Set error trap; source env hook; ECR login; discovered account ID, with error, and then retry until success" {
  [[ -z $SKIP_SLOW ]] || skip "skipping slow test"
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_RETRIES=1
  export AWS_DEFAULT_REGION=us-east-1

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "sts get-caller-identity --query Account --output text : echo 888888888888" \
    "--region us-east-1 ecr get-login-password : exit 1" \
    "--region us-east-1 ecr get-login-password : echo hunter2"

  stub docker \
    "login --username AWS --password-stdin 888888888888.dkr.ecr.us-east-1.amazonaws.com : cat > /tmp/password-stdin ; echo logging in to docker"

  # I don't know whether error trapping is supported in Bats (it's not mentioned in the docs), or how control flow would work after a trap was triggered (e.g. making assertions, cleanup). So we're shoving it all in a script to encapsulate it.
  run ${PWD}/tests/jigs/trap-and-source-env-hook.sh

  assert_success

  refute_output --partial "TRAP TRIGGERED"
  assert_output --partial "Login failed on attempt 1 of 2. Trying again in 1 seconds.."
  assert_output --partial "logging in to docker"

  assert_equal "hunter2" "$(cat /tmp/password-stdin)"

  unstub aws
  unstub docker
  rm /tmp/password-stdin
}

@test "Set error trap; source env hook; ECR login; discovered account ID, with error, and then retry until failure" {
  [[ -z $SKIP_SLOW ]] || skip "skipping slow test"
  export BUILDKITE_PLUGIN_ECR_LOGIN=true
  export BUILDKITE_PLUGIN_ECR_RETRIES=1
  export AWS_DEFAULT_REGION=us-east-1

  stub aws \
    "--version : echo aws-cli/2.0.0 Python/3.8.1 Linux/5.5.6-arch1-1 botocore/1.15.3" \
    "sts get-caller-identity --query Account --output text : echo 888888888888" \
    "--region us-east-1 ecr get-login-password : exit 1" \
    "--region us-east-1 ecr get-login-password : exit 1"

  run $PWD/tests/jigs/trap-and-source-env-hook.sh

  assert_failure

  assert_output --partial "Login failed on attempt 1 of 2. Trying again in 1 seconds.."
  assert_output --partial "Login failed after 2 attempts"
  assert_output --partial "TRAP TRIGGERED"

  unstub aws
}
