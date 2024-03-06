#!/usr/bin/env bash

set -Eeuo pipefail

handle_err() {
  echo "TRAP TRIGGERED" >&2
  exit 53
}

trap handle_err ERR

source hooks/environment
