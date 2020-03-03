#!/usr/bin/env bats
load '/usr/local/lib/bats/load.bash'
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
