#!/usr/bin/env bats

load test_helper

SERVER_URL="http://server.url"
API_KEY="APIKEY"

setup() {
  stub uname "-s : echo Darwin"
  stub osascript
  stub basename
}

teardown() {
  unstub uname
  unstub osascript
  unstub basename
}

@test "Notifies that file is being uploaded" {
  stub basename "/path/to/thing.gcode : echo thing.gcode"
  stub osascript "-e 'display notification \"notify: Uploading file \"thing.gcode\" with title \"Simplify3D\"' : exit 0"

  run ./octoprint.sh -g "/path/to/thing.gcode" -s $SERVER_URL -k $API_KEY

  assert_success
}
