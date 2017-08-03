#!/usr/bin/env bats

load test_helper
GROUP=$(test_name)

setup() {
  shellmock_clean
  shellmock_expect osascript --match "" --type partial
  shellmock_expect curl --match "" --type partial
  shellmock_expect basename --output "thing.gcode" --match "" --type partial
}

teardown() {
  shellmock_clean
}

@test "${GROUP} Succeeds if system is macOS" {
  shellmock_expect uname --output "Darwin" --match "" --type partial

  run ./octoprint.sh -k "API_KEY" -g "/path/to/thing.gcode" -s "http://serverurl"

  assert_success
  refute_output --partial "octoprint.sh is currently only compatible with macOS."
}

@test "${GROUP} Fails if system is not macOS" {
  shellmock_expect uname --output "Linux" --match "" --type partial

  run ./octoprint.sh -k "API_KEY" -g "/path/to/thing.gcode" -s "http://serverurl"

  assert_failure
  assert_output --partial "octoprint.sh is currently only compatible with macOS."
}
