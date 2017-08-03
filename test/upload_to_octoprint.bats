#!/usr/bin/env bats

load test_helper
GROUP=$(test_name)

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

@test "${GROUP} Notifies that file is being uploaded" {
  shellmock_stub basename --output "thing.gcode"
  shellmock_stub curl

  run ./octoprint.sh -g "/path/to/thing.gcode" -s $SERVER_URL -k $API_KEY

  shellmock_verify
  assert_success
}

@test "${GROUP} Changes spaces to underscores in file name" {
  shellmock_stub basename --output "my file.gcode"
  shellmock_stub curl

  run ./octoprint.sh -g "/path/to/my file.gcode" -s $SERVER_URL -k $API_KEY

  shellmock_verify
  assert_success
}

@test "${GROUP} Attempts to delete file with matching name already on server" {
  shellmock_stub basename --output "thing.gcode"
  shellmock_stub curl

  run ./octoprint.sh -g $GCODE_FILE -s $SERVER_URL -k $API_KEY

  shellmock_verify
  assert_success
}

@test "${GROUP} Ignores failure if deleting file fails" {
  shellmock_stub basename --output "thing.gcode"
  shellmock_expect curl --match "DELETE" --type partial --status 1
  shellmock_expect curl --match "PRINT" --type partial

  run ./octoprint.sh -g $GCODE_FILE -s $SERVER_URL -k $API_KEY

  assert_stub_called curl "-X DELETE ${SERVER_URL}/api/files/local/thing.gcode"
  assert_success
}

@test "${GROUP} Uploads gcode file to server" {
  shellmock_stub basename --output "thing.gcode"
  shellmock_stub curl

  run ./octoprint.sh -g $GCODE_FILE -s $SERVER_URL -k $API_KEY

  assert_stub_called curl "-F file=@thing.gcode ${SERVER_URL}/api/files/local"
  assert_success
}

@test "${GROUP} Deletes file after upload" {
  shellmock_stub basename --output "thing.gcode"
  shellmock_stub curl

  run ./octoprint.sh -g $GCODE_FILE -s $SERVER_URL -k $API_KEY

  assert_stub_called osascript "tell app \"Finder\" to delete POSIX file \"${GCODE_FILE}\""
  assert_success
}

@test "${GROUP} Does not delete file if upload failed" {
  shellmock_stub basename --output "thing.gcode"
  shellmock_expect curl --match "DELETE" --type partial
  shellmock_expect curl --match "PRINT" --type partial --status 1

  run ./octoprint.sh -g $GCODE_FILE -s $SERVER_URL -k $API_KEY

  assert_stub_not_called osascript "delete"
  assert_success
}
