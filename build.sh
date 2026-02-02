#!/bin/sh
set -ue

. ./config.sh

echo "--- $0"

# make sure dirs exist
if [ ! -d "$SYSROOT" ]; then
    sls_log "SYSROOT does not exist, creating"
    for dir in dev proc sys tmp; do
        mkdir -p "$SYSROOT/$dir"
    done
    cp -r tmpl-sysroot/* $SYSROOT
fi

if [ ! -d "$INITRD" ]; then
    sls_log "INITRD does not exist, creating"
    for dir in dev proc sys tmp mnt; do
        mkdir -p "$INITRD/$dir"
    done
    cp -r tmpl-initrd/* $INITRD
fi

# cross compiler
if [ ! -d "musl-cross-make" ]; then
    sls_log "./musl-cross-make does not exist, cloning and building"
    git clone https://github.com/richfelker/musl-cross-make --depth 1
    cd musl-cross-make
    cp $BASE/musl-cross-make-config.mk config.mak
    make # do not use -j$BUILD_JOBS
    cd $BASE
fi

if [ ! -d "$CROSS" ]; then
    sls_log "CROSS does not exist, installing"
    cd musl-cross-make
    make install
    cd $BASE
fi

# pkgs
for pkg in $PKGS/*; do
    sls_var PKG_BASE "$pkg"
    sls_var PKG_NAME "$(basename $PKG_BASE)"
    sls_var PKG_SRC "$PKG_BASE/src"
    sls_var PKG_SYSROOT "$PKG_BASE/sysroot"
    echo "--- building package $PKG_NAME"

    if [ ! -d "$PKG_SRC" ]; then
        cd $PKG_BASE
        $PKG_BASE/build.sh clone
        cd $PKG_SRC
        $PKG_BASE/build.sh build
    fi

    if [ ! -d "$PKG_SYSROOT" ]; then
        mkdir $PKG_SYSROOT
        cd $PKG_SRC
        $PKG_BASE/build.sh install
        cp $PKG_BASE/$PKG_NAME.deps $PKG_SYSROOT/
    fi

    if [ ! -f "$PKG_BASE/$PKG_NAME.sls" ]; then
        cd $PKG_SYSROOT
        tar --zstd -cf $PKG_BASE/$PKG_NAME.sls .
    fi

    cd $BASE
done

# initrd
for pkg in musl sbase ubase dash; do
    if [ ! -f "$INITRD/etc/sls/$pkg.files" ]; then
        DESTDIR=$INITRD ./sls install $PKGS/$pkg/$pkg.sls
    fi
done

# base system
for pkg in linux musl sbase ubase sinit dash oksh zstd rc.shutdown sls page mandoc; do
    if [ ! -f "$SYSROOT/etc/sls/$pkg.files" ]; then
        DESTDIR=$SYSROOT ./sls install $PKGS/$pkg/$pkg.sls
    fi
done

# nuke stuff in initrd
if [ -d "$INITRD/usr/share/man" ] || [ -d "$INITRD/usr/include" ]; then
    sls_log "nuking unnecessary files from INITRD"
    rm -rf $INITRD/usr/share/man $INITRD/usr/include
fi

# initramfs
if [ ! -f "$SYSROOT/boot/initramfs.cpio.gz" ]; then
    sls_log "SYSROOT/boot/initramfs.cpio.gz does not exist, creating"
    cd $INITRD
    find . -print0 | cpio --null -ov --format=newc | gzip -9 > $SYSROOT/boot/initramfs.cpio.gz
    cd $BASE
fi

# boot media
if [ ! -f "sls.iso" ]; then
    sls_log "sls.iso does not exist, creating"
    grub-mkrescue -o sls.iso sysroot/ -- -volid SLS_LINUX_ISO
fi


sls_log "reached end"
