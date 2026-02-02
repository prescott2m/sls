#!/bin/sh
set -ue

case $1 in
clone)
    git clone https://github.com/clark800/page src --depth 1
    ;;
build)
    CC=$TARGET_TUPLE-gcc ./make
    ;;
install)
    mkdir -pv $PKG_SYSROOT/usr/bin
    cp -v $PKG_SRC/fpipe $PKG_SRC/page $PKG_SYSROOT/usr/bin/
    ;;
*)
    echo "invalid op"
    ;;
esac
