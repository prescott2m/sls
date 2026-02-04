#!/bin/sh
set -ue

case $1 in
clone)
    git clone https://github.com/facebook/zstd src --depth 1
    ;;
build)
    make -j$BUILD_JOBS CC=$TARGET_TUPLE-gcc AR=$TARGET_TUPLE-ar
    ;;
install)
    make install DESTDIR=$PKG_DESTDIR PREFIX=/usr
    ;;
*)
    echo "invalid op"
    ;;
esac
