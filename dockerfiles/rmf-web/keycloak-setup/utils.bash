#!/usr/bin/env bash

# exit codes: 
#   0: success
#   1: general error exit
#   2: lockfile present

set -o errexit
set -o nounset
set -o pipefail
trap 'catch $? $LINENO' EXIT

catch() {
  __cleanup
  if [ "$1" != "2" ]; then
      __unlock
  fi
}

: "${LOG_ERROR:=1}"
: "${LOG_DEBUG:=1}"
: "${LOG_INFO:=1}"
: "${PROJECT:=project}"
PROJECT_TMP=/tmp/$PROJECT

function __cleanup() {
    __msg_debug "Cleaning up"
}

__error_exit() {
    line=$1
    shift 1
    __msg_error "non zero return code from line: $line — $*" >&2
    exit 1
}

__msg_error() {
    { [[ "${LOG_ERROR}" == "1" ]] && echo -e "[ERROR]: $*" >&2; } || true
}

__msg_warn() {
    { [[ "${LOG_ERROR}" == "1" ]] && echo -e "[WARN]: $*" >&2; } || true
}

__msg_debug() {
    { [[ "${LOG_DEBUG}" == "1" ]] && echo -e "[DEBUG]: $*" >&2; } || true
}

__msg_info() {
    { [[ "${LOG_INFO}" == "1" ]] && echo -e "[INFO]: $*" >&2; } || true
}

__random_string() {
    tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo ''
}

__lock() {
    [ ! -f "$PROJECT_TMP/.$PROJECT.lock" ] || { __msg_error "Lockfile present at $PROJECT_TMP" && exit 2; }
    __msg_info "Generating Lockfile at $PROJECT_TMP/.$PROJECT.lock"
    mkdir -p "$PROJECT_TMP"
    touch "$PROJECT_TMP/.$PROJECT.lock"
}

__unlock() {
    __msg_info "Removing Lockfile"
    rm "$PROJECT_TMP/.$PROJECT.lock" 2> /dev/null
}

__lock
