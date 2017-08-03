#!/bin/bash

trap 'exit' SIGHUP SIGINT SIGTERM SIGQUIT
trap 'printf "${NC}\n"; stty icanon echo echok' EXIT

WHT='\033[0;37m'
CYN='\033[0;36m'
RED='\033[0;31m'
GRN='\033[0;32m'
NC='\033[0m' # No Color

function main() {
  parse_launch_args "$@"
  assert_supported_os
  upload_gcode_to_octoprint
}

function upload_gcode_to_octoprint() {
  local GCODE_FILE_NAME=$( basename "${GCODE_FILE_PATH}" )
  SPACE=" "
  local GCODE_FILE_NAME_ESCAPED=${GCODE_FILE_NAME/$SPACE/_}
  notify "Uploading file '${GCODE_FILE_NAME_ESCAPED}'"

  $(curl --connect-timeout 15 -H "Content-Type: multipart/form-data" -H "X-Api-Key: ${OCTOPRINT_API_KEY}" -X "DELETE" "${OCTOPRINT_SERVER_URL}/api/files/local/${GCODE_FILE_NAME_ESCAPED}") || true
  $(curl --connect-timeout 15 -H "Content-Type: multipart/form-data" -H "X-Api-Key: ${OCTOPRINT_API_KEY}" -F "SELECT" -F "PRINT" -F "USER_DATA" -F "file=@${GCODE_FILE_NAME_ESCAPED}" "${OCTOPRINT_SERVER_URL}/api/files/local")
  if [ $? -eq 0 ]; then
    trash $GCODE_FILE_PATH
  fi
}

function assert_supported_os() {
  OS=$(uname -s)
  if [[ "${OS}" != "Darwin" ]] ; then
    error "octoprint.sh is currently only compatible with macOS."
    exit 1
  fi
}

function parse_launch_args() {
  while getopts ":s:k:g:" o; do
    case "${o}" in
      s)
        OCTOPRINT_SERVER_URL=${OPTARG}
        ;;
      k)
        OCTOPRINT_API_KEY=${OPTARG}
        ;;
      g)
        GCODE_FILE_PATH=${OPTARG}
        ;;
      *)
        print_cmd_usage_and_fail
        ;;
    esac
  done
  shift $((OPTIND-1))

  if [ -z "${OCTOPRINT_SERVER_URL}" ] || [ -z "${OCTOPRINT_API_KEY}" ] || [ -z "${GCODE_FILE_PATH}" ]; then
    print_cmd_usage_and_fail
  fi
}

function print_cmd_usage_and_fail() {
  printf "${WHT}Usage: $0 -s ${CYN}<OCTOPRINT_URL>${WHT} -k ${CYN}<API_KEY>${WHT} -g ${CYN}<GCODE_FILE_PATH>${NC}\n"
  exit 1
}

function show_notification() {
  QUOTE='"'
  ESCAPED_QUOTE='\"'
  MESSAGE=${1//$QUOTE/$ESCAPED_QUOTE}
  osascript -e 'display notification "'"${MESSAGE}"'" with title "Simplify3D"'
}

function notify() {
  printf "notify: ${1}\n"
  show_notification "${1}"
}

function error() {
  printf "error: ${1}\n"
  show_notification "${1}"
}

function success() {
  printf "success: ${1}\n"
  show_notification "${1}"
}

function trash() {
  printf "trash: ${1}\n"
  osascript -e 'tell app "Finder" to delete POSIX file "'"${1}"'"'
}

main "$@"
