#!/bin/sh
set -ue

case $1 in
clone)
    git clone git://git.suckless.org/sbase src --depth 1
    ;;
build)
    cp $PKG_BASE/config.mk $PKG_SRC/config.mk
    make -j$BUILD_JOBS
    ;;
install)
    make install DESTDIR=$PKG_DESTDIR
    ;;
*)
    echo "invalid op"
    ;;
esac
