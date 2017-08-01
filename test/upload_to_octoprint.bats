#!/usr/bin/env bats
load test_helper

SERVER_URL="http://server.url"
API_KEY="APIKEY"

setup() {
  stub uname "echo Darwin"
  stub osascript "exit 0"
}

teardown() {
  unstub uname --quiet
  unstub osascript --quiet
}

@test "Notifies that file is being uploaded" {
  stub curl "exit 0"
  stub basename "echo thing.gcode"

  run ./octoprint.sh -g "/path/to/thing.gcode" -s $SERVER_URL -k $API_KEY

  assert_success
  unstub basename
  unstub curl --quiet
}

@test "Changes spaces to underscores in file name" {
  stub curl "exit 0"
  stub basename "echo \"my file.gcode\""

  run ./octoprint.sh -g "/path/to/my file.gcode" -s $SERVER_URL -k $API_KEY

  assert_success
  unstub basename
  unstub curl --quiet
}

@test "Attempts to delete file with matching name already on server" {
  SERVER_URL="http://my.server"
  API_KEY="MY_API_KEY"
  GCODE_FILE="/path/to/my_file.gcode"
  stub curl "--connect-timeout 15 -H \"Content-Type: multipart/form-data\" -H \"X-Api-Key: MY_API_KEY\" -X \"DELETE\" \"http://my.server/api/files/local/my_file.gcode\" : exit 0"

  run ./octoprint.sh -g $GCODE_FILE -s $SERVER_URL -k $API_KEY

  echo $output
  assert_success
  unstub curl
}
