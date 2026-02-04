#!/bin/sh
set -ue

case $1 in
clone)
    cp -r local-src src
    ;;
build)
    make
    ;;
install)
    make install DESTDIR=$PKG_DESTDIR
    ;;
*)
    echo "invalid op"
    ;;
esac
