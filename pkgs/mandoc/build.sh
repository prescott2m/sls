#!/bin/sh
set -ue

case $1 in
clone)
    wget https://mandoc.bsd.lv/snapshots/mandoc.tar.gz
    tar -xzvf mandoc.tar.gz
    rm mandoc.tar.gz
    mv mandoc-* src
    ;;
build)
    patch -p1 < $PKG_BASE/no-zlib.diff
    cp $PKG_BASE/configure.local $PKG_SRC/configure.local
    ./configure
    make -j$BUILD_JOBS
    ;;
install)
    make install DESTDIR=$PKG_SYSROOT
    ;;
*)
    echo "invalid op"
    ;;
esac
