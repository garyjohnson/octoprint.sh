#!/usr/bin/env bats

load test_helper

setup() {
  stub osascript
  stub basename "echo test.gcode"
  stub curl "exit 0"
}

teardown() {
  unstub osascript --quiet
  unstub basename --quiet
  unstub curl --quiet
}

@test "Succeeds if system is macOS" {
  stub uname "-s : echo Darwin"

  run ./octoprint.sh -k "API_KEY" -g "/path/to/thing.gcode" -s "http://serverurl"

  assert_success
  refute_output --partial "octoprint.sh is currently only compatible with macOS."
  unstub uname
}

@test "Fails if system is not macOS" {
  stub uname "-s : echo Linux"

  run ./octoprint.sh -k "API_KEY" -g "/path/to/thing.gcode" -s "http://serverurl"

  assert_failure
  assert_output --partial "octoprint.sh is currently only compatible with macOS."
  unstub uname
}
