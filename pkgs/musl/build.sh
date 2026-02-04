#!/bin/sh
set -ue

case $1 in
clone)
    git clone git://git.musl-libc.org/musl src --depth 1
    ;;
build)
    ./configure --host=$TARGET_TUPLE --prefix=/usr --syslibdir=/lib
    make -j$BUILD_JOBS
    ;;
install)
    make install DESTDIR=$PKG_DESTDIR
    ;;
*)
    echo "invalid op"
    ;;
esac
