#!/bin/sh
set -ue

# helpers
sls_var() {
    eval "$1=\"\$2\""
    export "$1"
    eval "val=\$$1"
    printf '%s=\e[94m%s\e[0m\n' "$1" "$val"
}

sls_log() {
    printf -- "- \e[94m$*\e[0m\n"
}

# vars
sls_var TARGET_TUPLE x86_64-linux-musl
sls_var BASE "$(pwd)"
sls_var PKGS "$BASE/pkgs"
sls_var CROSS "$BASE/cross"
sls_var SYSROOT "$BASE/sysroot"
sls_var INITRD "$BASE/initrd"
sls_var BUILD_JOBS $(nproc)
sls_var AUTOTOOLS_CONFIGURE_FLAGS "--host=$TARGET_TUPLE --prefix=/usr CC=$TARGET_TUPLE-gcc CXX=$TARGET_TUPLE-g++ AR=$TARGET_TUPLE-ar RANLIB=$TARGET_TUPLE-ranlib STRIP=$TARGET_TUPLE-strip"
sls_var PATH "$CROSS/bin:$PATH"
