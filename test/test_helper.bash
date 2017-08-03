export PATH="$PATH:$PWD/test/libs/bats_shell_mock/bin"
. shellmock
load 'libs/bats-support/load'
load 'libs/bats-assert/load'

function join_by() {
  local IFS="$1"
  shift
  echo "$*"
}

function shellmock_stub() {
  local cmd=$1
  shift
  shellmock_expect $cmd --match "" --type partial "$@"
}

function assert_stub_called() {
  local expected_cmd="$1"
  shift
  local expected_args="$@"

  shellmock_verify

  was_called=0
  with_args=0
  for i in "${capture[@]}"; do
    IFS=" " read -r command args <<< "${i}"
    if [[ ${command} == "${expected_cmd}-stub" ]]; then
      was_called=1
    fi

    if [[ $was_called -eq 1 ]] && [[ "${args}" == *"${expected_args}"* ]]; then
      with_args=1
    fi
  done

  local captures=$(join_by $'\n' "${capture[@]}")

  if [[ $was_called -ne 1 ]] && [[ $with_args -ne 1 ]]; then
    echo -e "\"${expected_cmd}\" was not called with args \"${expected_args}\".\n\nCalls to stubbed commands:\n${captures}\n" | fail
  elif [[ $was_called -eq 1 ]] && [[ $with_args -ne 1 ]]; then
    echo -e "\"${expected_cmd}\" was called, but not with args \"${expected_args}\".\n\nCalls to stubbed commands:\n${captures}\n" | fail
  fi
}

function assert_stub_not_called() {
  local expected_cmd="$1"
  shift
  local expected_args="$@"

  shellmock_verify

  was_called=0
  with_args=0
  for i in "${capture[@]}"; do
    IFS=" " read -r command args <<< "${i}"
    if [[ ${command} == "${expected_cmd}-stub" ]]; then
      was_called=1
    fi

    if [[ $was_called -eq 1 ]] && [[ "${args}" == *"${expected_args}"* ]]; then
      with_args=1
    fi
  done

  local captures=$(join_by $'\n' "${capture[@]}")

  if [[ $was_called -eq 1 ]] && [[ $with_args -eq 1 ]]; then
    echo -e "\"${expected_cmd}\" was called with args \"${expected_args}\".\n\nCalls to stubbed commands:\n${captures}\n" | fail
  fi
}

function test_name() {
  space=" "
  underscore="_"

  me=$(basename -s ".bats" "${BATS_TEST_FILENAME}")
  me=${me//$underscore/$space}
  me=$(echo "${me}" | awk '{print toupper($0)}')
  echo "${me} |"
}
