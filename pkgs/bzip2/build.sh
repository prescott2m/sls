#!/bin/sh
set -ue

case $1 in
clone)
    git clone https://gitlab.com/bzip2/bzip2.git src --depth 1
    ;;
build)
    patch -p1 < $PKG_BASE/no-docs-tests.diff 
    CC=$TARGET_TUPLE-gcc LD=$TARGET_TUPLE-ld AR=$TARGET_TUPLE-ar muon setup -Dprefix=$PKG_DESTDIR/usr build
    samu -C build
    ;;
install)
    samu -C build install
    ;;
*)
    echo "invalid op"
    ;;
esac
