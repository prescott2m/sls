#!/bin/sh
set -ue

. ./config.sh

echo "--- $0"

usage() {
    echo "usage: $0 [-isulc]"
    echo " -: sls.iso"
    echo " i: initrd"
    echo " s: sysroot"
    echo " u: cloned repos (except for linux and musl-cross-make)"
    echo " l: linux kernel"
    echo " c: cross compiler"
    exit 2
}

targets="sls.iso"

if [ "$#" = "0" ]; then
    usage
fi

while getopts "isulc" opt; do
    case "$opt" in
    i) targets="$targets $INITRD $SYSROOT/boot/initramfs.cpio.gz" ;; # initrd
    s) targets="$targets $SYSROOT" ;; # sysroot
    u) targets="$targets musl dash oksh sbase ubase sinit rc.shutdown/rc.shutdown" ;; # userland
    l) targets="$targets linux $SYSROOT/boot/bzImage" ;; # linux
    c) targets="$targets $CROSS musl-cross-make" ;; # cross
    *) usage ;;
    esac
done

if [ -n "$targets" ]; then
	printf "REMOVING: \e[91m$targets\e[0m\n"
	rm -rf $targets
fi
