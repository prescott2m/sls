#!/bin/sh
set -ue

case $1 in
clone)
    git clone git://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git src --depth 1
    ;;
build)
    ./configure $AUTOTOOLS_CONFIGURE_FLAGS --disable-nls --disable-fuse2fs \
        --disable-backtrace --disable-debugfs --disable-fsck --disable-uuidd \
        --enable-lto --enable-libuuid --enable-libblkid --sbindir=/usr/bin
    
    make -j$BUILD_JOBS
    ;;
install)
    make install DESTDIR=$PKG_DESTDIR
    ;;
*)
    echo "invalid op"
    ;;
esac
