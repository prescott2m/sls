#!/bin/sh
set -ue

case $1 in
clone)
    mkdir src
    ;;
build)
    ;;
install)
    mkdir -pv $PKG_DESTDIR/usr/bin
    cp -v $BASE/sls $PKG_DESTDIR/usr/bin/sls
    ;;
*)
    echo "invalid op"
    ;;
esac
