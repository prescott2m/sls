#!/bin/sh
set -ue

case $1 in
clone)
    git clone https://github.com/mkj/dropbear.git src --depth 1
    ;;
build)
    ./configure $AUTOTOOLS_CONFIGURE_FLAGS --disable-zlib --disable-syslog --sbindir=/usr/bin
    make -j$BUILD_JOBS PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp"
    ;;
install)
    make install PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" DESTDIR=$PKG_DESTDIR
    ;;
*)
    echo "invalid op"
    ;;
esac
