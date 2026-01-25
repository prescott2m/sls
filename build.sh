#!/bin/bash
set -e

. config.sh

echo "---"

# make sure dirs exist
if [ ! -d "$SYSROOT" ]; then
	sl_log "SYSROOT does not exist, creating"
	mkdir -p $SYSROOT/{dev,proc,root,sys}
	cp -r tmpl-sysroot/* $SYSROOT
fi

if [ ! -d "$INITRD" ]; then
	sl_log "INITRD does not exist, creating"
	mkdir -p $INITRD/{dev,proc,tmp,mnt}
	cp -r tmpl-initrd/* $INITRD
fi

# linux
if [ ! -d "linux" ]; then
	sl_log "./linux does not exist, cloning and building"
	git clone https://github.com/torvalds/linux -j$(nproc) --depth=1
	cd linux
	make defconfig
	patch .config ../linux-config.patch
	make -j$(nproc)
	cd $BASE
fi

if [ ! -f "$SYSROOT/boot/bzImage" ]; then
	sl_log "SYSROOT/boot/bzImage does not exist, copying"
	cp -v linux/arch/x86/boot/bzImage $SYSROOT/boot/bzImage
fi

# musl
if [ ! -d "musl-$MUSL_VERSION" ]; then
	sl_log "./musl-$MUSL_VERSION does not exist, cloning and building"
	wget https://musl.libc.org/releases/musl-$MUSL_VERSION.tar.gz
	tar -xzvf musl-$MUSL_VERSION.tar.gz
	cd musl-$MUSL_VERSION
	./configure --prefix=/usr --syslibdir=/lib
	make -j$(nproc)
	DESTDIR=$SYSROOT make install
	DESTDIR=$INITRD make install
	cd $BASE
fi

if [ ! -L "$SYSROOT/lib/ld-musl-x86_64.so.1" ]; then
	sl_log "SYSROOT/lib/ld-musl-x86_64.so.1 does not exist, installing"
	cd musl-$MUSL_VERSION
	DESTDIR=$SYSROOT make install
	cd $BASE
fi

if [ ! -L "$INITRD/lib/ld-musl-x86_64.so.1" ]; then
	sl_log "INITRD/lib/ld-musl-x86_64.so.1 does not exist, installing"
	cd musl-$MUSL_VERSION
	DESTDIR=$INITRD make install
	cd $BASE

	sl_log "nuking compiler and headers from INITRD"
	rm -rf $INITRD/usr/include $INITRD/usr/bin
fi

# sbase
if [ ! -d "sbase" ]; then
	sl_log "./sbase does not exist, cloning and building"
	git clone git://git.suckless.org/sbase -j$(nproc) --depth 1
	cp sbase-config.mk sbase/config.mk
	cd sbase
	make -j$(nproc)
	cd $BASE
fi

if [ ! -f "$SYSROOT/usr/bin/ls" ]; then
	sl_log "SYSROOT sbase utils do not exist, installing"
	cd sbase
	rm -f proto
	make install DESTDIR=$SYSROOT
	cd $BASE
fi

if [ ! -f "$INITRD/usr/bin/ls" ]; then
	sl_log "INITRD sbase utils do not exist, installing"
	cd sbase
	rm -f proto
	make install DESTDIR=$INITRD
	cd $BASE
fi

# ubase
if [ ! -d "ubase" ]; then
	sl_log "./ubase does not exist, cloning and building"
	git clone git://git.suckless.org/ubase -j$(nproc) --depth 1
	cp ubase-config.mk ubase/config.mk
	cd ubase
	make -j$(nproc)
	cd $BASE
fi

if [ ! -f "$SYSROOT/usr/bin/mount" ]; then
	sl_log "SYSROOT ubase utils do not exist, installing"
	cd ubase
	rm -f proto
	make install DESTDIR=$SYSROOT
	cd $BASE
fi

if [ ! -f "$INITRD/usr/bin/mount" ]; then
	sl_log "INITRD ubase utils do not exist, installing"
	cd ubase
	rm -f proto
	make install DESTDIR=$INITRD
	cd $BASE
fi

# sinit
if [ ! -d "sinit" ]; then
	sl_log "./sinit does not exist, cloning and building"
	git clone git://git.suckless.org/sinit -j$(nproc) --depth 1
	cp sinit-config.mk sinit/config.mk
	cd sinit
	make
	cd $BASE
fi

if [ ! -f "$SYSROOT/usr/bin/sinit" ]; then
	sl_log "SYSROOT/bin/sinit does not exist, installing"
	cd sinit
	make install DESTDIR=$SYSROOT
	cd $BASE
fi

# dash
if [ ! -d "dash-$DASH_VERSION" ]; then
	sl_log "./dash-$DASH_VERSION does not exist, cloning and building"
	wget https://git.kernel.org/pub/scm/utils/dash/dash.git/snapshot/dash-$DASH_VERSION.tar.gz
	tar -xzvf dash-$DASH_VERSION.tar.gz
	cd dash-$DASH_VERSION
	./autogen.sh
	./configure --host=$TARGET_TUPLE
	make -j$(nproc)
	cd $BASE
fi

if [ ! -f "$SYSROOT/usr/bin/sh" ]; then
	sl_log "SYSROOT/usr/bin/sh does not exist, copying dash"
	cp -v dash-$DASH_VERSION/src/dash $SYSROOT/usr/bin/sh
fi

if [ ! -f "$INITRD/usr/bin/sh" ]; then
	sl_log "INITRD/usr/bin/sh does not exist, copying dash"
	cp -v dash-$DASH_VERSION/src/dash $INITRD/usr/bin/sh
fi

# nuke stuff in initrd
if [ -d "$INITRD/usr/share/man" ]; then
	sl_log "nuking manpages from INITRD"
	rm -rf $INITRD/usr/share/man
fi

# initramfs
if [ ! -f "$SYSROOT/boot/initramfs.cpio.gz" ]; then
	sl_log "SYSROOT/boot/initramfs.cpio.gz does not exist, creating"
	cd $INITRD
	find . -print0 | cpio --null -ov --format=newc | gzip -9 > $SYSROOT/boot/initramfs.cpio.gz
	cd $BASE
fi

# boot media
if [ ! -f "slinux.iso" ]; then
	sl_log "slinux.iso does not exist, creating"
	grub-mkrescue -o slinux.iso sysroot/
fi


sl_log "reached end"
