#!/usr/bin/env bats
load test_helper

SERVER_URL="http://server.url"
API_KEY="APIKEY"

setup() {
  shellmock_clean
  shellmock_expect uname --output "Darwin" --match "" --type partial
  shellmock_expect osascript --match "" --type partial
}

teardown() {
  shellmock_clean
}

@test "Notifies that file is being uploaded" {
  shellmock_expect curl --match "" --type partial
  shellmock_expect basename --output "thing.gcode" --match "" --type partial

  run ./octoprint.sh -g "/path/to/thing.gcode" -s $SERVER_URL -k $API_KEY

  assert_success
  shellmock_verify
}

@test "Changes spaces to underscores in file name" {
  shellmock_expect curl --match "" --type partial
  shellmock_expect basename --output "my file.gcode" --match "" --type partial

  run ./octoprint.sh -g "/path/to/my file.gcode" -s $SERVER_URL -k $API_KEY

  assert_success
  shellmock_verify
}

@test "Attempts to delete file with matching name already on server" {
  SERVER_URL="http://my.server"
  API_KEY="MY_API_KEY"
  GCODE_FILE="/path/to/my_file.gcode"
  shellmock_expect basename --output "thing.gcode" --match "" --type partial
  shellmock_expect curl --match "--connect-timeout 15 -H \"Content-Type: multipart/form-data\" -H \"X-Api-Key: MY_API_KEY\" -X \"DELETE\" \"http://my.server/api/files/local/my_file.gcode\"" --type partial

  run ./octoprint.sh -g $GCODE_FILE -s $SERVER_URL -k $API_KEY

  assert_success
  shellmock_verify
}
