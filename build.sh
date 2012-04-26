#!/bin/sh

fail() { echo "Compilation failed!" ; exit 1; }

cd fakechroot
[ -e configure ] || ./autogen.sh || fail
[ -e config.h ] || ./configure --host=arm-linux-gnueabi --prefix=/usr || fail
make -j4 && cp -f src/.libs/libfakechroot.so .. && arm-linux-gnueabi-strip -g ../libfakechroot.so || fail
cd ..

cd c-ares
[ -e ares_config.h ] || ./configure --host=arm-linux-gnueabi --prefix=/usr || fail
make && cp -f .libs/libcares.so ../libfakedns.so && arm-linux-gnueabi-strip -g ../libfakedns.so || fail
cd ..

cd androidVNC/ZoomerWithKeys
[ -e local.properties ] || android update project -p . || fail
ant debug || fail
cd ../androidVNC
[ -e local.properties ] || android update project -p . || fail
ant debug && cp -f bin/Ubuntu-debug.apk ../.. || fail
cd ../..
