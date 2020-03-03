#!/usr/bin/env bats
load '/usr/local/lib/bats/load.bash'
load "$PWD/hooks/environment"

@test "version_a_gte_b: version compare: equal" {
  run version_a_gte_b 1.2.3 1.2.3
  assert_success
}
@test "version_a_gte_b: version compare: simple major version success" {
  run version_a_gte_b 2.0.0 1.0.0
  assert_success
}
@test "version_a_gte_b: version compare: simple major version failure" {
  run version_a_gte_b 1.0.0 2.0.0
  assert_failure
}
@test "version_a_gte_b: simple minor version success" {
  run version_a_gte_b 1.2.0 1.1.0
  assert_success
}
@test "version_a_gte_b: simple minor version failure" {
  run version_a_gte_b 1.1.0 1.2.0
  assert_failure
}
@test "version_a_gte_b: simple patch version success" {
  run version_a_gte_b 1.2.1 1.2.0
  assert_success
}
@test "version_a_gte_b: simple patch version failure" {
  run version_a_gte_b 1.2.0 1.2.1
  assert_failure
}
@test "version_a_gte_b: smaller major but bigger minor; failure" {
  run version_a_gte_b 1.4.0 2.3.0
  assert_failure
}
@test "version_a_gte_b: smaller minor but bigger patch; failure" {
  run version_a_gte_b 1.4.8 1.6.2
  assert_failure
}
