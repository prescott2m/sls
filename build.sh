#!/bin/bash
set -ue

. config.sh

echo "---"

# make sure dirs exist
if [ ! -d "$SYSROOT" ]; then
	sl_log "SYSROOT does not exist, creating"
	mkdir -p $SYSROOT/{dev,proc,sys,tmp}
	cp -r tmpl-sysroot/* $SYSROOT
fi

if [ ! -d "$INITRD" ]; then
	sl_log "INITRD does not exist, creating"
	mkdir -p $INITRD/{dev,proc,sys,tmp,mnt}
	cp -r tmpl-initrd/* $INITRD
fi

# linux
if [ ! -d "linux" ]; then
	sl_log "./linux does not exist, cloning and building"
	git clone https://github.com/torvalds/linux --depth 1
	cd linux
	make defconfig
	patch .config $BASE/linux-config.diff
	make -j$BUILD_JOBS
	cd $BASE
fi

if [ ! -f "$SYSROOT/boot/bzImage" ]; then
	sl_log "SYSROOT/boot/bzImage does not exist, copying"
	cp -v linux/arch/x86/boot/bzImage $SYSROOT/boot/bzImage
fi

# cross compiler
if [ ! -d "musl-cross-make" ]; then
	sl_log "./musl-cross-make does not exist, cloning and building"
	git clone https://github.com/richfelker/musl-cross-make --depth 1
	cd musl-cross-make
    cp $BASE/musl-cross-make-config.mk config.mak
	make
    make install
	cd $BASE
fi

# musl
if [ ! -d "musl" ]; then
	sl_log "./musl does not exist, cloning and building"
	git clone git://git.musl-libc.org/musl --depth 1
	cd musl
	./configure --host=$TARGET_TUPLE --prefix=/usr --syslibdir=/lib
	make -j$BUILD_JOBS
	DESTDIR=$SYSROOT make install
	DESTDIR=$INITRD make install
	cd $BASE
fi

if [ ! -L "$SYSROOT/lib/ld-musl-x86_64.so.1" ]; then
	sl_log "SYSROOT/lib/ld-musl-x86_64.so.1 does not exist, installing"
	cd musl
	DESTDIR=$SYSROOT make install
	cd $BASE
fi

if [ ! -L "$INITRD/lib/ld-musl-x86_64.so.1" ]; then
	sl_log "INITRD/lib/ld-musl-x86_64.so.1 does not exist, installing"
	cd musl
	DESTDIR=$INITRD make install
	cd $BASE

	sl_log "nuking compiler and headers from INITRD"
	rm -rf $INITRD/usr/include $INITRD/usr/bin
fi

# sbase
if [ ! -d "sbase" ]; then
	sl_log "./sbase does not exist, cloning and building"
	git clone git://git.suckless.org/sbase --depth 1
	cp sbase-config.mk sbase/config.mk
	cd sbase
	make -j$BUILD_JOBS
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
	git clone git://git.suckless.org/ubase --depth 1
	cp ubase-config.mk ubase/config.mk
	cd ubase
	make -j$BUILD_JOBS
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
	git clone git://git.suckless.org/sinit --depth 1
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

# rc.shutdown
if [ ! -f "rc.shutdown/rc.shutdown" ]; then
	sl_log "./rc.shutdown/rc.shutdown does not exist, building"
	cd rc.shutdown
	make
	cd $BASE
fi

if [ ! -f "$SYSROOT/usr/bin/rc.shutdown" ]; then
	sl_log "SYSROOT/bin/rc.shutdown does not exist, installing"
	cd rc.shutdown
	make install DESTDIR=$SYSROOT
	cd $BASE
fi

# dash
if [ ! -d "dash" ]; then
	sl_log "./dash does not exist, cloning and building"
	git clone git://git.kernel.org/pub/scm/utils/dash/dash.git --depth 1
	cd dash
	./autogen.sh
	./configure $AUTOTOOLS_CONFIGURE_FLAGS
	make -j$BUILD_JOBS
	cd $BASE
fi

if [ ! -f "$SYSROOT/usr/bin/sh" ]; then
	sl_log "SYSROOT/usr/bin/sh does not exist, copying dash"
	cp -v dash/src/dash $SYSROOT/usr/bin/sh
fi

if [ ! -f "$INITRD/usr/bin/sh" ]; then
	sl_log "INITRD/usr/bin/sh does not exist, copying dash"
	cp -v dash/src/dash $INITRD/usr/bin/sh
fi

# oksh
if [ ! -d "oksh" ]; then
	sl_log "./oksh does not exist, cloning and building"
	git clone https://github.com/ibara/oksh oksh
	cd oksh
	./configure --cc=$TARGET_TUPLE-gcc --disable-curses --enable-ksh --prefix=/usr
	make -j$BUILD_JOBS
	cd $BASE
fi

if [ ! -f "$SYSROOT/usr/bin/ksh" ]; then
	sl_log "SYSROOT/usr/bin/ksh does not exist, installing"
	cd oksh
	make install DESTDIR=$SYSROOT
	cd $BASE
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
if [ ! -f "sls.iso" ]; then
	sl_log "sls.iso does not exist, creating"
	grub-mkrescue -o sls.iso sysroot/ -- -volid SLS_LINUX_ISO
fi


sl_log "reached end"
