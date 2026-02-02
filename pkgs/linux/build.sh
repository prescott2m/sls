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
    mkdir -pv $PKG_SYSROOT/boot
    cp -v $PKG_SRC/arch/x86/boot/bzImage $PKG_SYSROOT/boot/bzImage
    ;;
*)
    echo "invalid op"
    ;;
esac
