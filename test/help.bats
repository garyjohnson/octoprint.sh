#!/usr/bin/env bats

load test_helper
GROUP=$(test_name)

setup() {
  shellmock_clean
  shellmock_expect uname --output "Darwin" --match "" --type partial
  shellmock_expect osascript --match "" --type partial
  shellmock_expect curl --match "" --type partial
  shellmock_expect basename --output "thing.gcode" --match "" --type partial
}

teardown() {
  shellmock_clean
}

@test "${GROUP} Shows help usage if no args provided" {
  run ./octoprint.sh

  assert_output --partial "Usage:"
  assert_failure
}

@test "${GROUP} Shows help usage if some args provided" {
  run ./octoprint.sh -k "API_KEY" -g "/path/to/thing.gcode"

  assert_output --partial "Usage:"
  assert_failure
}

@test "${GROUP} Does not show help usage if all args provided" {
  run ./octoprint.sh -k "API_KEY" -g "/path/to/thing.gcode" -s "http://serverurl"

  refute_output --partial "Usage:"
  assert_success
}
