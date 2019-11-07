#!/bin/sh

fail() { echo "Compilation failed!" ; exit 1; }

ARCH_LIST="arm64-v8a x86_64 armeabi-v7a x86"

for ARCH in $ARCH_LIST; do

	export ARCH=$ARCH

	mkdir -p dist-$ARCH

	[ -e dist-$ARCH/libdisableselinux.so ] || {
		./setCrossEnvironment-$ARCH.sh sh -c ' \
			$CC $CFLAGS $LDFLAGS -shared disableselinux/*.c -o dist-$ARCH/libdisableselinux.so && \
			$STRIP dist-$ARCH/libdisableselinux.so' || fail
	} || fail

	[ -e dist-$ARCH/libandroid-shmem.so ] || {

		cd android-shmem
		../setCrossEnvironment-$ARCH.sh sh -c ' \
			$CC $CFLAGS $LDFLAGS -llog -shared -std=gnu99 *.c -I . -I libancillary \
			-o ../dist-$ARCH/libandroid-shmem.so -Wl,--version-script=exports.txt && \
			$STRIP ../dist-$ARCH/libandroid-shmem.so' || fail
		cd ..
	} || fail

	[ -e talloc-2.1.0.tar.gz ] || wget http://www.samba.org/ftp/talloc/talloc-2.1.0.tar.gz || fail

	continue # BUILD SCRIPT REWORK IN PROGRESS

[ -e libtalloc-$ARCH.a ] || {
	[ -e talloc-2.1.0 ] || tar xvzf talloc-2.1.0.tar.gz || fail
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

done
