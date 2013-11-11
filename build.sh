#!/bin/sh

fail() { echo "Compilation failed!" ; exit 1; }

cd fakechroot
[ -e configure ] || ./autogen.sh || fail
[ -e config.h ] || ./configure --host=arm-linux-gnueabihf --prefix=/usr || fail
[ -e ../libfakechroot.so ] || { make -j4 CFLAGS="-march=armv7-a" LDFLAGS="-march=armv7-a" V=1 && cp -f src/.libs/libfakechroot.so .. && arm-linux-gnueabihf-strip ../libfakechroot.so || fail ; }
cd ..

cd c-ares
[ -e ares_config.h ] || ./configure --enable-shared --host=arm-linux-gnueabihf --prefix=/usr || fail
[ -e ../libfakedns.so ] || { make -j4 CFLAGS="-march=armv7-a" LDFLAGS="-march=armv7-a" && cp -f .libs/libcares.so ../libfakedns.so && arm-linux-gnueabihf-strip ../libfakedns.so || fail ; }
cd ..

