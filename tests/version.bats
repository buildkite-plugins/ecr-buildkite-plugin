#!/usr/bin/env bats

load "${BATS_PLUGIN_PATH}/load.bash"

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
