#!/bin/bash

if [[ $1 == "all" ]]; then
	rm -rf linux musl* dash* sbase ubase sinit bash* sysroot initrd initramfs.cpio.gz slinux.iso
elif [[ $1 == "userland" ]]; then
	rm -rf musl* dash* sbase ubase sinit bash* sysroot initrd initramfs.cpio.gz slinux.iso
elif [[ $1 == "fs" ]]; then
	rm -rf sysroot initrd initramfs.cpio.gz slinux.iso
else
	echo "help:"
	echo "./clean.sh all - deletes sysroot, initrd, and cloned repos"
	echo "./clean.sh userland - deletes sysroot, initrd, and cloned repos (except linux)"
	echo "./clean.sh fs  - deletes sysroot and initrd"
fi
