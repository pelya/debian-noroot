#!/bin/sh

fail() { echo "Compilation failed!" ; exit 1; }

cd fakechroot
[ -e configure ] || ./autogen.sh || fail
[ -e config.h ] || ./configure --host=arm-linux-gnueabihf --prefix=/usr || fail
[ -e ../libfakechroot.so ] || {
	make -j4 CFLAGS="-march=armv7-a -fpic" LDFLAGS="-march=armv7-a" V=1 && \
	cp -f src/.libs/libfakechroot.so .. && \
	arm-linux-gnueabihf-strip ../libfakechroot.so || fail
} || exit 1
cd ..

cd c-ares
[ -e ares_config.h ] || LIBS=-Wl,--version-script=exports.txt \
	./configure --enable-shared --host=arm-linux-gnueabihf --prefix=/usr || fail
[ -e ../libfakedns.so ] || {
	make -j4 CFLAGS="-march=armv7-a -fpic" LDFLAGS="-march=armv7-a" libcares.la && \
	cp -f .libs/libcares.so ../libfakedns.so && \
	arm-linux-gnueabihf-strip ../libfakedns.so || fail
} || exit 1
cd ..

[ -e libfakedns.so ] || {
	arm-linux-gnueabihf-gcc -march=armv7-a -shared -fpic fakedns/*.c -I c-ares c-ares/.libs/libcares.a -o libfakedns.so && \
	arm-linux-gnueabihf-strip libfakedns.so || fail
} || exit 1

[ -e libdisableselinux.so ] || {
	arm-linux-gnueabihf-gcc -march=armv7-a -shared -fpic disableselinux/*.c -o libdisableselinux.so && \
	arm-linux-gnueabihf-strip libdisableselinux.so || fail
} || exit 1

[ -e libandroid-shmem.so ] || {
	[ -e android-shmem/LICENSE ] || {
		cd ..
		git submodule update --init android/android-shmem || fail
		cd $BUILDDIR
	} || exit 1
	[ -e android-shmem/libancillary/ancillary.h ] || {
		cd android-shmem
		git submodule update --init libancillary || fail
		cd ..
	} || exit 1

	cd android-shmem
	arm-linux-gnueabihf-gcc -march=armv7-a -shared -fpic -std=gnu99 *.c -I . -I libancillary \
		-o ../libandroid-shmem.so -Wl,--version-script=exports.txt -lc -lpthread && \
	arm-linux-gnueabihf-strip ../libandroid-shmem.so || fail
	cd ..
} || exit 1
