#!/usr/bin/env bash

set -Eeuo pipefail

handle_err() {
  echo "^^^ +++"
  echo ":alert: Elastic CI Stack environment hook failed" >&2
  exit 53
}

trap handle_err ERR

export BUILDKITE_PLUGIN_ECR_RETRIES=3
export BUILDKITE_PLUGIN_ECR_LOGIN=1

trap - ERR
source hooks/environment
trap handle_err ERR

