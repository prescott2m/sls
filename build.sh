#!/bin/bash
set -e

# vars
export MUSL_VERSION=1.2.5
export DASH_VERSION=0.5.13
export BASH_VERSION=5.3
export TARGET_TUPLE=x86_64-linux-musl
export SYSROOT=$(pwd)/sysroot
export INITRD=$(pwd)/initrd

echo "MUSL_VERSION=$MUSL_VERSION"
echo "DASH_VERSION=$DASH_VERSION"
echo "TARGET_TUPLE=$TARGET_TUPLE"
echo "SYSROOT=$SYSROOT"
echo "---"

# make sure dirs exist
if [ ! -d "$SYSROOT" ]; then
	echo "SYSROOT does not exist, creating"
	mkdir -p $SYSROOT/{dev,proc,root,sys}
	cp -r tmpl-sysroot/* $SYSROOT
fi

if [ ! -d "$INITRD" ]; then
	echo "INITRD does not exist, creating"
	mkdir -p $INITRD/{dev,proc,mnt}
	cp -r tmpl-initrd/* $INITRD
fi

# linux
if [ ! -d "linux" ]; then
	echo "couldn't find ./linux dir, cloning and building"
	git clone https://github.com/torvalds/linux -j$(nproc) --depth=1
	cd linux
	make defconfig
	patch .config ../linux-config.patch
	make -j$(nproc)
	cd ..
fi

if [ ! -f "$SYSROOT/boot/bzImage" ]; then
	echo "SYSROOT/boot/bzImage does not exist, copying"
	cp -v linux/arch/x86/boot/bzImage $SYSROOT/boot/bzImage
fi

# musl
if [ ! -d "musl-$MUSL_VERSION" ]; then
	echo "couldn't find ./musl-$MUSL_VERSION dir, downloading and building"
	wget https://musl.libc.org/releases/musl-$MUSL_VERSION.tar.gz
	tar -xzvf musl-$MUSL_VERSION.tar.gz
	cd musl-$MUSL_VERSION
	./configure --prefix=/usr --syslibdir=/lib
	make -j$(nproc)
	DESTDIR=$SYSROOT make install
	DESTDIR=$INITRD make install
	cd ..
fi

if [ ! -L "$SYSROOT/lib/ld-musl-x86_64.so.1" ]; then
	echo "SYSROOT/lib/ld-musl-x86_64.so.1 does not exist, installing"
	cd musl-$MUSL_VERSION
	DESTDIR=$SYSROOT make install
	cd ..
fi

if [ ! -L "$INITRD/lib/ld-musl-x86_64.so.1" ]; then
	echo "INITRD/lib/ld-musl-x86_64.so.1 does not exist, installing"
	cd musl-$MUSL_VERSION
	DESTDIR=$INITRD make install
	cd ..

	echo "nuking compiler and headers from INITRD"
	rm -rf $INITRD/usr/include $INITRD/usr/bin
fi

# sbase
if [ ! -d "sbase" ]; then
	echo "couldn't find ./sbase dir, cloning and building"
	git clone git://git.suckless.org/sbase -j$(nproc) --depth 1
	cp sbase-config.mk sbase/config.mk
	cd sbase
	make -j$(nproc)
	cd ..
fi

if [ ! -f "$SYSROOT/usr/bin/ls" ]; then
	echo "SYSROOT sbase utils do not exist, installing"
	cd sbase
	rm -f proto
	make install DESTDIR=$SYSROOT
	cd ..
fi

if [ ! -f "$INITRD/usr/bin/ls" ]; then
	echo "INITRD sbase utils do not exist, installing"
	cd sbase
	rm -f proto
	make install DESTDIR=$INITRD
	cd ..
fi

# ubase
if [ ! -d "ubase" ]; then
	echo "couldn't find ./ubase dir, cloning and building"
	git clone git://git.suckless.org/ubase -j$(nproc) --depth 1
	cp ubase-config.mk ubase/config.mk
	cd ubase
	make -j$(nproc)
	cd ..
fi

if [ ! -f "$SYSROOT/usr/bin/mount" ]; then
	echo "SYSROOT ubase utils do not exist, installing"
	cd ubase
	rm -f proto
	make install DESTDIR=$SYSROOT
	cd ..
fi

if [ ! -f "$INITRD/usr/bin/mount" ]; then
	echo "INITRD ubase utils do not exist, installing"
	cd ubase
	rm -f proto
	make install DESTDIR=$INITRD
	cd ..
fi

# sinit
if [ ! -d "sinit" ]; then
	echo "couldn't find ./sinit dir, cloning and building"
	git clone git://git.suckless.org/sinit -j$(nproc) --depth 1
	cp sinit-config.mk sinit/config.mk
	cd sinit
	make
	cd ..
fi

if [ ! -f "$SYSROOT/usr/bin/sinit" ]; then
	echo "SYSROOT sinit does not exist, installing"
	cd sinit
	make install DESTDIR=$SYSROOT
	cd ..
fi

# dash
if [ ! -d "dash-$DASH_VERSION" ]; then
	echo "couldn't find ./dash-$DASH_VERSION dir, downloading and building"
	wget https://git.kernel.org/pub/scm/utils/dash/dash.git/snapshot/dash-$DASH_VERSION.tar.gz
	tar -xzvf dash-$DASH_VERSION.tar.gz
	cd dash-$DASH_VERSION
	./autogen.sh
	./configure --host=$TARGET_TUPLE
	make -j$(nproc)
	cd ..
fi

if [ ! -f "$SYSROOT/usr/bin/sh" ]; then
	echo "SYSROOT/usr/bin/sh does not exist, copying dash"
	cp -v dash-$DASH_VERSION/src/dash $SYSROOT/usr/bin/sh
fi

if [ ! -f "$INITRD/usr/bin/sh" ]; then
	echo "INITRD/usr/bin/sh does not exist, copying dash"
	cp -v dash-$DASH_VERSION/src/dash $INITRD/usr/bin/sh
fi

# bash
if [ ! -d "bash-$BASH_VERSION" ]; then
	echo "couldn't find ./bash-$BASH_VERSION dir, downloading and building"
	wget https://ftp.gnu.org/gnu/bash/bash-$BASH_VERSION.tar.gz
	tar -xzvf bash-$BASH_VERSION.tar.gz
	cd bash-$BASH_VERSION
	./configure --host=x86_64-linux-musl --without-bash-malloc
	make -j$(nproc)
	cd ..
fi

if [ ! -f "$SYSROOT/usr/bin/bash" ]; then
	echo "SYSROOT/usr/bin/bash does not exist, copying bash"
	cp -v bash-$BASH_VERSION/bash $SYSROOT/usr/bin/bash
fi

# neofetch
if [ ! -f "$SYSROOT/usr/bin/neofetch" ]; then
	echo "SYSROOT/usr/bin/neofetch does not exist, downloading"
	wget https://raw.githubusercontent.com/dylanaraps/neofetch/refs/heads/master/neofetch -O $SYSROOT/usr/bin/neofetch
	chmod +x $SYSROOT/usr/bin/neofetch
fi

# nuke stuff in initrd
if [ -d "$INITRD/usr/share/man" ]; then
	echo "nuking manpages from INITRD"
	rm -rf $INITRD/usr/share/man
fi

# initramfs
cd initrd
find . -print0 | cpio --null -ov --format=newc | gzip -9 > $SYSROOT/boot/initramfs.cpio.gz
cd ..

# boot media
grub-mkrescue -o slinux.iso sysroot/


echo "reached end"
