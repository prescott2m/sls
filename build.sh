#!/bin/sh
set -ue

. ./config.sh

echo "--- $0"

build_pkg() {
    sls_var PKG_BASE "$1"
    sls_var PKG_NAME "$(basename $PKG_BASE)"
    sls_var PKG_SRC "$PKG_BASE/src"
    sls_var PKG_SYSROOT "$PKG_BASE/sysroot"
    sls_log "building package $PKG_NAME"

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
}

# make sure dirs exist
if [ ! -d "$SYSROOT" ]; then
    sls_log "SYSROOT does not exist, creating"
    for dir in dev dev/pts proc sys tmp; do
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

# priority packages first
for pkg in $PRIORITY_PKGS; do
    build_pkg "$PKGS/$pkg"

    sls_log "installing $PKG_NAME to SYSROOT"
    if [ ! -f "$SYSROOT/etc/sls/$pkg.files" ]; then
        DESTDIR=$SYSROOT ./sls install $PKGS/$pkg/$pkg.sls
    fi
done

# everything else
for pkg in $PKGS/*; do
    PKG_NAME=$(basename $pkg)
    for x in $PRIORITY_PKGS; do [ "$PKG_NAME" = "$x" ] && continue 2; done

    build_pkg "$pkg"

    sls_log "installing $PKG_NAME to SYSROOT"
    if [ ! -f "$SYSROOT/etc/sls/$pkg.files" ]; then
        DESTDIR=$SYSROOT ./sls install $pkg/$PKG_NAME.sls
    fi
done

# initrd
for pkg in musl sbase ubase dash; do
    sls_log "installing $pkg to INITRD"
    if [ ! -f "$INITRD/etc/sls/$pkg.files" ]; then
        DESTDIR=$INITRD ./sls install $PKGS/$pkg/$pkg.sls
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
