#!/bin/sh
set -ue

case $1 in
clone)
    git clone https://github.com/ibara/oksh src --depth 1
    ;;
build)
    ./configure --cc=$TARGET_TUPLE-gcc --disable-curses --enable-ksh --prefix=/usr
    make -j$BUILD_JOBS
    ;;
install)
    make install DESTDIR=$PKG_SYSROOT
    ;;
*)
    echo "invalid op"
    ;;
esac
