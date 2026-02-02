#!/bin/sh
set -uef

# helpers
sls_log() {
    printf -- "- \e[94m$*\e[0m\n"
}

sls_err() {
    printf -- "- \e[91m$*\e[0m\n"
    exit 1
}

sls_absolute_filepath() {
    dir=$(dirname -- "$1") &&
    base=$(basename -- "$1") &&
    cd -- "$dir" 2>/dev/null &&
    printf '%s/%s\n' "$(pwd -P)" "$base"
}

usage() {
    echo "usage: [DESTDIR=DIR] [NODEPERR=1] $0 install|remove|list [PKG]"
    echo " DESTDIR=DIR: Operate on DIR instead of /"
    echo " NODEPERR=1:  Do not error out on a missing dependency"
    echo " install:     Install PKG (.sls file) to / or DIR specified by DESTDIR"
    echo " remove:      Remove PKG (pkg name) from / or DIR specified by DESTDIR"
    echo " list:        Lists all installed packages"
    echo " PKG:         Operate on package PKG"
    exit 2
}

# entry
if [ $# -eq 0 ] || \
    ([ $# -eq 1 ] && ([ "$1" = "install" ] || [ "$1" = "remove" ])) || \
    ([ $# -gt 1 ] && [ "$1" = "list" ]); then usage; fi

SLS_DEST="/"

# destdir? set. otherwise? check root
if [ "${DESTDIR-}" != "" ]; then
    SLS_DEST=$(cd -- "$DESTDIR" 2>/dev/null && pwd -P)
elif [ "$1" != "list" ] && [ "$(id -u)" -ne 0 ]; then
    sls_err "you must be root"
fi

sls_log "operating on \e[4m$SLS_DEST\e[24m"

if [ ! -d "$SLS_DEST/etc/sls" ]; then
    sls_log "creating $SLS_DEST/etc/sls"
    mkdir -p "$SLS_DEST/etc/sls"
fi

cd "$SLS_DEST"

case $1 in
install)
    if [ ! -f "$2" ]; then sls_err "$2: requested package doesn't exist"; fi
    SLS_PKG=$(sls_absolute_filepath $2)
    SLS_PKG_NAME="$(basename $(basename $SLS_PKG) .sls)"
    SLS_TAR_FILE="/tmp/$SLS_PKG_NAME.tar"

    zstd -dfc -o $SLS_TAR_FILE -- "$SLS_PKG"
    tar -C "$SLS_DEST/etc/sls" -xf $SLS_TAR_FILE ./$SLS_PKG_NAME.deps

    if [ "${NODEPERR-}" = "" ]; then
        while read -r line; do
            if [ ! -f "$SLS_DEST/etc/sls/$line.files" ]; then
                rm $SLS_TAR_FILE
                rm "$SLS_DEST/etc/sls/$SLS_PKG_NAME.deps"
                sls_err "$SLS_PKG_NAME: missing dep: $line"
            fi
        done < "$SLS_DEST/etc/sls/$SLS_PKG_NAME.deps"
    fi

    tar -xvf $SLS_TAR_FILE --no-same-owner --no-same-permissions --exclude="$SLS_PKG_NAME.deps"
    tar -tf $SLS_TAR_FILE | grep -v '/$' | grep -v "$SLS_PKG_NAME.deps" > "$SLS_DEST/etc/sls/$SLS_PKG_NAME.files"
    ;;
remove)
    if [ ! -f "$SLS_DEST/etc/sls/$2.files" ]; then sls_err "$2: requested package doesn't exist"; fi
    while read -r line; do
        rm -f "$(sls_absolute_filepath $line)"
        rm -f "$SLS_DEST/etc/sls/$2.files"
        rm -f "$SLS_DEST/etc/sls/$2.deps"
    done < "$SLS_DEST/etc/sls/$2.files"
    ;;
list)
    ls "$SLS_DEST/etc/sls" | sed -n 's/\.files$//p'
    ;;
*)
    usage
esac
