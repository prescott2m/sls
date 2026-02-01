#!/bin/bash
set -ue

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
sl_var TARGET_TUPLE x86_64-linux-musl
sl_var BASE "$(pwd)"
sl_var CROSS "$BASE/cross"
sl_var SYSROOT "$BASE/sysroot"
sl_var INITRD "$BASE/initrd"
sl_var BUILD_JOBS $(nproc)
sl_var AUTOTOOLS_CONFIGURE_FLAGS "--host=$TARGET_TUPLE CC=$TARGET_TUPLE-gcc CXX=$TARGET_TUPLE-g++ AR=$TARGET_TUPLE-ar RANLIB=$TARGET_TUPLE-ranlib STRIP=$TARGET_TUPLE-strip"

sl_var PATH "$CROSS/bin:$PATH"