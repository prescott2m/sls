#!/bin/sh
set -ue

. ./config.sh

echo "--- $0"

usage() {
    echo "usage: $0 [-isac] [-p PKG]"
    echo " -: sls.iso"
    echo " i: initrd"
    echo " s: sysroot"
    echo " a: all pkgs"
    echo " c: cross compiler"
    echo " p: just one pkg"
    exit 2
}

targets="sls.iso"

if [ "$#" = "0" ]; then
    usage
fi

while getopts "isacp:" opt; do
    case "$opt" in
    i) targets="$targets $INITRD $SYSROOT/boot/initramfs.cpio.gz" ;; # initrd
    s) targets="$targets $SYSROOT" ;; # sysroot
    a) targets="$targets $PKGS/*/src $PKGS/*/sysroot $PKGS/*/destdir $PKGS/*/*.sls" ;; # all pkgs
    c) targets="$targets $CROSS musl-cross-make" ;; # cross
    p) targets="$targets $PKGS/$OPTARG/src $PKGS/$OPTARG/sysroot $PKGS/$OPTARG/destdir $PKGS/$OPTARG/$OPTARG.sls" ;; # just one pkg
    *) usage ;;
    esac
done

if [ -n "$targets" ]; then
	printf "REMOVING: \e[91m$targets\e[0m\n"
	rm -rf $targets
fi
