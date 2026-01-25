#!/bin/bash

if [[ $1 == "all" ]]; then
	rm -rf linux musl* dash* sbase ubase sinit bash* sysroot initrd slinux.iso
elif [[ $1 == "userland" ]]; then
	rm -rf musl* dash* sbase ubase sinit bash* sysroot initrd slinux.iso
elif [[ $1 == "initrd" ]]; then
	rm -rf initrd sysroot/boot/initramfs.cpio.gz slinux.iso
elif [[ $1 == "fs" ]]; then
	rm -rf sysroot initrd slinux.iso
else
	echo "help:"
	echo "./clean.sh all - deletes sysroot, initrd, slinux.iso, and cloned repos"
	echo "./clean.sh userland - deletes sysroot, initrd, slinux.iso, and cloned repos (except linux)"
	echo "./clean.sh initrd - deletes initrd and slinux.iso"
	echo "./clean.sh fs  - deletes sysroot, initrd, and slinux.iso"
fi
