#!/usr/bin/env bats

load test_helper

setup() {
  stub osascript
}

teardown() {
  unstub osascript
  unstub uname
}

@test "Succeeds if system is macOS" {
  stub uname "-s : echo Darwin"

  run ./octoprint.sh -k "API_KEY" -g "/path/to/thing.gcode" -s "http://serverurl"

  assert_success
  refute_output --partial "octoprint.sh is currently only compatible with macOS."
}

@test "Fails if system is not macOS" {
  stub uname "-s : echo Linux"

  run ./octoprint.sh -k "API_KEY" -g "/path/to/thing.gcode" -s "http://serverurl"

  assert_failure
  assert_output --partial "octoprint.sh is currently only compatible with macOS."
}
