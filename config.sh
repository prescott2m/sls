#!/bin/bash
set -e

# helpers
sl_var() {
  printf -v "$1" '%s' "$2"
  export "$1"
  printf '%s=\e[94m%s\e[0m\n' "$1" "${!1}"
}

sl_log() {
	echo -e "- \e[94m$*\e[0m"
}

# vars
sl_var MUSL_VERSION 1.2.5
sl_var DASH_VERSION 0.5.13
sl_var OKSH_VERSION 7.8
sl_var TARGET_TUPLE x86_64-linux-musl
sl_var SYSROOT "$(pwd)/sysroot"
sl_var INITRD "$(pwd)/initrd"
sl_var BASE "$(pwd)"