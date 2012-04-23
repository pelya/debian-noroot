#!/bin/sh

fail() { echo "Compilation failed!" ; exit 1; }

cd fakechroot
[ -e configure ] || ./autogen.sh || fail
[ -e config.h ] || ./configure --host=arm-linux-gnueabi --prefix=/usr || fail
make -j4 && cp -f src/.libs/libfakechroot.so .. && arm-linux-gnueabi-strip -g ../libfakechroot.so || fail
cd ..

cd xserver

