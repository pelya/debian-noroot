#!/bin/sh

fail() { echo "Compilation failed!" ; exit 1; }

false && { # ===== Do not compile libfakechroot and libfakedns, they are not used anymore =====

cd fakechroot
[ -e configure ] || ./autogen.sh || fail
[ -e config.h ] || ./configure --host=arm-linux-gnueabihf --prefix=/usr || fail
[ -e ../libfakechroot.so ] || {
	make -j4 CFLAGS="-march=armv7-a -fpic" LDFLAGS="-march=armv7-a" V=1 && \
	cp -f src/.libs/libfakechroot.so .. && \
	arm-linux-gnueabihf-strip ../libfakechroot.so || fail
} || fail
cd ..

cd c-ares
[ -e ares_config.h ] || LIBS=-Wl,--version-script=exports.txt \
	./configure --enable-shared --host=arm-linux-gnueabihf --prefix=/usr || fail
[ -e ../libfakedns.so ] || {
	make -j4 CFLAGS="-march=armv7-a -fpic" LDFLAGS="-march=armv7-a" libcares.la && \
	cp -f .libs/libcares.so ../libfakedns.so && \
	arm-linux-gnueabihf-strip ../libfakedns.so || fail
} || fail
cd ..

[ -e libfakedns.so ] || {
	arm-linux-gnueabihf-gcc -march=armv7-a -shared -fpic fakedns/*.c -I c-ares c-ares/.libs/libcares.a -o libfakedns.so && \
	arm-linux-gnueabihf-strip libfakedns.so || fail
} || fail

} # ===== libfakechroot and libfakedns =====

[ -e dist/libdisableselinux.so ] || {
	arm-linux-gnueabihf-gcc -march=armv7-a -shared -fpic disableselinux/*.c -o dist/libdisableselinux.so && \
	arm-linux-gnueabihf-strip dist/libdisableselinux.so || fail
} || fail

[ -e dist/libandroid-shmem.so ] || {
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
	arm-linux-gnueabihf-gcc -march=armv7-a -shared -fpic -std=gnu99 -flto *.c -I . -I libancillary \
		-o ../dist/libandroid-shmem.so -Wl,--version-script=exports.txt -lc -lpthread && \
	arm-linux-gnueabihf-strip ../dist/libandroid-shmem.so || fail
	cd ..
} || fail

[ -e libtalloc.a ] || {
	[ -e talloc-2.1.0 ] || curl http://www.samba.org/ftp/talloc/talloc-2.1.0.tar.gz | tar xvz || fail
	cd talloc-2.1.0
	make clean
	env CC=arm-linux-gnueabihf-gcc CFLAGS="-flto -fpic" LD=arm-linux-gnueabihf-gcc LDFLAGS="-flto" ./configure build --cross-compile --cross-execute='qemu-arm-static /usr/arm-linux-gnueabihf/lib/ld-linux.so.3 --library-path /usr/arm-linux-gnueabihf/lib' || fail
	#cp -f libtalloc.so ../libtalloc.so || fail
	ar rcs ../libtalloc.a bin/default/talloc*.o # bin/default/lib/replace/replace*.o 
	cd ..
} || fail

[ -e dist/proot ] || {
	cd proot-src
	git clean -f -d -x
	git checkout -f
	patch -p1 < ../proot-android.patch || fail
	cd src
	ln -sf `which arm-linux-gnueabihf-strip` strip
	ln -sf `which arm-linux-gnueabihf-objcopy` objcopy
	ln -sf `which arm-linux-gnueabihf-objdump` objdump
	env PATH=`pwd`:$PATH CC=arm-linux-gnueabihf-gcc \
		CFLAGS="-I../../talloc-2.1.0 -Wall -Wextra -O2 -flto -fpic" \
		LDFLAGS="-L../.. -ltalloc -static -flto" \
		V=1 make -e || fail
	rm -f strip objcopy objdump
	cp proot ../../dist/
	cd ../..
	arm-linux-gnueabihf-strip dist/proot
} || fail

CFLAGSx86="-march=i686 -mtune=atom -mstackrealign -msse3 -mfpmath=sse -m32 -flto -fpic"

[ -e dist-x86/libdisableselinux.so ] || {
	gcc $CFLAGSx86 -shared -fpic disableselinux/*.c -o dist-x86/libdisableselinux.so && \
	strip dist-x86/libdisableselinux.so || fail
} || fail

[ -e dist-x86/libandroid-shmem.so ] || {
	cd android-shmem
	gcc $CFLAGSx86 -shared -fpic -std=gnu99 *.c -I . -I libancillary \
		-o ../dist-x86/libandroid-shmem.so -Wl,--version-script=exports.txt -lc -lpthread && \
	strip ../dist-x86/libandroid-shmem.so || fail
	cd ..
} || fail

[ -e libtalloc-x86.a ] || {
	cd talloc-2.1.0
	make clean
	env CC=gcc CFLAGS="$CFLAGSx86 -fno-lto" LD=gcc LDFLAGS="$CFLAGSx86 -fno-lto" ./configure build || fail
	#cp -f libtalloc.so ../libtalloc.so || fail
	ar rcs ../libtalloc-x86.a bin/default/talloc*.o # bin/default/lib/replace/replace*.o 
	cd ..
} || fail

[ -e dist-x86/proot ] || {
	cd proot-src
	git clean -f -d -x
	git checkout -f
	patch -p1 < ../proot-android.patch || fail
	cd src
	env CC="gcc $CFLAGSx86" \
		CFLAGS="-I../../talloc-2.1.0 -Wall -Wextra -O2" \
		LDFLAGS="-L../.. -ltalloc-x86 -static" \
		V=1 make -e || fail
	cp proot ../../dist-x86/
	cd ../..
	strip dist-x86/proot
} || fail
