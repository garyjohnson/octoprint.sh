#!/usr/bin/env bats

load test_helper

@test "Shows help usage if no args provided" {
  run ./octoprint.sh

  assert_output --partial "Usage:"
  assert_failure
}

@test "Shows help usage if some args provided" {
  run ./octoprint.sh -k "API_KEY" -g "/path/to/thing.gcode"

  assert_output --partial "Usage:"
  assert_failure
}

@test "Does not show help usage if all args provided" {
  stub basename "echo \"thing.gcode\""
  stub uname "-s : echo Darwin"
  stub osascript "exit 0"
  stub curl "exit 0"

  run ./octoprint.sh -k "API_KEY" -g "/path/to/thing.gcode" -s "http://serverurl"

  refute_output --partial "Usage:"
  assert_success
  unstub basename --quiet
  unstub osascript --quiet
  unstub uname --quiet
  unstub curl --quiet
}
