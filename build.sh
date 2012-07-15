#!/bin/sh

fail() { echo "Compilation failed!" ; exit 1; }

cd fakechroot
[ -e configure ] || ./autogen.sh || fail
[ -e config.h ] || ./configure --host=arm-linux-gnueabi --prefix=/usr || fail
[ -e ../libfakechroot.so ] || { make -j4 CFLAGS="-march=armv5te -msoft-float" LDFLAGS="-march=armv5te -msoft-float" V=1 && cp -f src/.libs/libfakechroot.so .. && arm-linux-gnueabi-strip ../libfakechroot.so || fail ; }
cd ..

cd c-ares
[ -e ares_config.h ] || ./configure --enable-shared --host=arm-linux-gnueabi --prefix=/usr || fail
[ -e ../libfakedns.so ] || { make -j4 CFLAGS="-march=armv5te -msoft-float" LDFLAGS="-march=armv5te -msoft-float" && cp -f .libs/libcares.so ../libfakedns.so && arm-linux-gnueabi-strip ../libfakedns.so || fail ; }
cd ..

cd androidVNC/ZoomerWithKeys
[ -e local.properties ] || android update project -p . || fail
ant debug || fail
cd ../androidVNC
rm -rf bin/*
[ -e local.properties ] || android update project -p . || fail
ant debug && cp -f bin/Ubuntu-debug.apk ../.. || fail
cd ../..
