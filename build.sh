#!/bin/sh

fail() { echo "Compilation failed!" ; exit 1; }

cd fakechroot
[ -e configure ] || ./autogen.sh || fail
[ -e config.h ] || ./configure --host=arm-linux-gnueabihf --prefix=/usr || fail
[ -e ../libfakechroot.so ] || {
	make -j4 CFLAGS="-march=armv7-a" LDFLAGS="-march=armv7-a" V=1 && \
	cp -f src/.libs/libfakechroot.so .. && \
	arm-linux-gnueabihf-strip ../libfakechroot.so || fail
}
cd ..

cd c-ares
[ -e ares_config.h ] || LIBS=-Wl,--version-script=exports.txt \
	./configure --enable-shared --host=arm-linux-gnueabihf --prefix=/usr || fail
[ -e ../libfakedns.so ] || {
	make -j4 CFLAGS="-march=armv7-a" LDFLAGS="-march=armv7-a" libcares.la && \
	cp -f .libs/libcares.so ../libfakedns.so && \
	arm-linux-gnueabihf-strip ../libfakedns.so || fail
}
cd ..

[ -e libfakedns.so ] || {
	arm-linux-gnueabihf-gcc -march=armv7-a -shared fakedns/*.c -I c-ares c-ares/.libs/libcares.a -o libfakedns.so && \
	arm-linux-gnueabihf-strip libfakedns.so || fail
}

[ -e libdisableselinux.so ] || {
	arm-linux-gnueabihf-gcc -march=armv7-a -shared disableselinux/*.c -o libdisableselinux.so && \
	arm-linux-gnueabihf-strip libdisableselinux.so || fail
}
