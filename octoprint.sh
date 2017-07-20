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
  check_os
  upload_gcode_to_octoprint
}

function check_os() {
  OS=$(uname -s)
  if [[ "${OS}" != "Darwin" ]] ; then
    error "octoprint.sh is currently only compatible with macOS."
    exit 1
  fi
}

function print_cmd_usage() {
  printf "${WHT}Usage: $0 -s ${CYN}<OCTOPRINT_URL>${WHT} -k ${CYN}<API_KEY>${WHT} -g ${CYN}<GCODE_FILE_PATH>${NC}\n"
  exit 1
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
        print_cmd_usage
        ;;
    esac
  done
  shift $((OPTIND-1))

  if [ -z "${OCTOPRINT_SERVER_URL}" ] || [ -z "${OCTOPRINT_API_KEY}" ] || [ -z "${GCODE_FILE_PATH}" ]; then
    print_cmd_usage
  fi
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

function upload_gcode_to_octoprint() {
  local GCODE_FILE_NAME=$( basename "${GCODE_FILE_PATH}" )
  notify "Uploading file \"${GCODE_FILE_NAME}\""
}

main "$@"
