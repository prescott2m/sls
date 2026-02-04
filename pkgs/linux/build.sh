#!/bin/sh
set -ue

case $1 in
clone)
    git clone https://github.com/torvalds/linux src --depth 1
    ;;
build)
    make defconfig
    patch .config $PKG_BASE/config.diff
    make -j$BUILD_JOBS
    ;;
install)
    mkdir -pv $PKG_DESTDIR/boot
    cp -v $PKG_SRC/arch/x86/boot/bzImage $PKG_DESTDIR/boot/bzImage
    make headers_install \
        ARCH=x86_64 \
        INSTALL_HDR_PATH="$PKG_DESTDIR/usr"
    ;;
*)
    echo "invalid op"
    ;;
esac
