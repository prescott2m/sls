#!/bin/sh
set -ue

case $1 in
clone)
    git clone git://git.kernel.org/pub/scm/utils/dash/dash.git src --depth 1
    ;;
build)
    ./autogen.sh
    ./configure $AUTOTOOLS_CONFIGURE_FLAGS
    make -j$BUILD_JOBS
    ;;
install)
    make install DESTDIR=$PKG_SYSROOT
    cd $PKG_SYSROOT/usr/bin
    ln -svf dash sh
    cd $PKG_SYSROOT/usr/share/man/man1
    ln -svf dash.1 sh.1
    ;;
*)
    echo "invalid op"
    ;;
esac
