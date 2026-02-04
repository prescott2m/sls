#!/bin/sh
set -ue

case $1 in
clone)
    wget http://deb.debian.org/debian/pool/main/e/e3/e3_$E3_VERSION.orig.tar.gz
    tar -xzvf e3_$E3_VERSION.orig.tar.gz
    rm e3_$E3_VERSION.orig.tar.gz
    mv e3-$E3_VERSION src
    ;;
build)
    patch -p1 < $PKG_BASE/no-symlinks.diff
    make 64 # x86_64
    ;;
install)
    make install PREFIX=$PKG_DESTDIR/usr MANDIR=$PKG_DESTDIR/usr/share/man/man1
    cd $PKG_DESTDIR/usr/bin

    for sym in e3ws e3em e3pi e3vi e3ne; do
        ln -sf e3 $sym
    done
    ;;
*)
    echo "invalid op"
    ;;
esac
