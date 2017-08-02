#!/usr/bin/env bats
load test_helper

SERVER_URL="http://my.server"
API_KEY="MY_API_KEY"
GCODE_FILE="/path/to/my_file.gcode"

setup() {
  shellmock_clean
  shellmock_stub uname --output "Darwin"
  shellmock_stub osascript
}

teardown() {
  shellmock_clean
}

@test "Notifies that file is being uploaded" {
  shellmock_stub basename --output "thing.gcode"
  shellmock_stub curl

  run ./octoprint.sh -g "/path/to/thing.gcode" -s $SERVER_URL -k $API_KEY

  shellmock_verify
  assert_success
}

@test "Changes spaces to underscores in file name" {
  shellmock_stub basename --output "my file.gcode"
  shellmock_stub curl

  run ./octoprint.sh -g "/path/to/my file.gcode" -s $SERVER_URL -k $API_KEY

  shellmock_verify
  assert_success
}

@test "Attempts to delete file with matching name already on server" {
  shellmock_stub basename --output "thing.gcode"
  shellmock_stub curl

  run ./octoprint.sh -g $GCODE_FILE -s $SERVER_URL -k $API_KEY

  shellmock_verify
  assert_success
}

@test "Ignores failure if deleting file fails" {
  shellmock_stub basename --output "thing.gcode"
  shellmock_expect curl --match "DELETE" --type partial --status 1
  shellmock_expect curl --match "PRINT" --type partial

  run ./octoprint.sh -g $GCODE_FILE -s $SERVER_URL -k $API_KEY

  assert_stub_called curl "-X DELETE ${SERVER_URL}/api/files/local/thing.gcode"
  assert_success
}

@test "Uploads gcode file to server" {
  shellmock_stub basename --output "thing.gcode"
  shellmock_stub curl

  run ./octoprint.sh -g $GCODE_FILE -s $SERVER_URL -k $API_KEY

  assert_stub_called curl "-F file=@thing.gcode ${SERVER_URL}/api/files/local"
  assert_success
}
