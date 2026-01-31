#!/bin/bash
set -ue

. config.sh

if [[ $1 == "all" ]]; then
	rm -rf linux musl dash oksh sbase ubase sinit rc.shutdown/rc.shutdown sysroot initrd sls.iso
elif [[ $1 == "userland" ]]; then
	rm -rf musl dash oksh sbase ubase sinit rc.shutdown/rc.shutdown sysroot initrd sls.iso
elif [[ $1 == "initrd" ]]; then
	rm -rf initrd sysroot/boot/initramfs.cpio.gz sls.iso
elif [[ $1 == "fs" ]]; then
	rm -rf sysroot initrd sls.iso
else
	echo "help:"
	echo "./clean.sh all - deletes sysroot, initrd, sls.iso, and cloned repos"
	echo "./clean.sh userland - deletes sysroot, initrd, sls.iso, and cloned repos (except linux)"
	echo "./clean.sh initrd - deletes initrd and sls.iso"
	echo "./clean.sh fs  - deletes sysroot, initrd, and sls.iso"
	exit 2
fi


