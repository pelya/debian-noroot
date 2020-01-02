#!/bin/sh

fail() { echo "Compilation failed!" ; exit 1; }

ARCH_LIST="arm64-v8a x86_64"

for ARCH in $ARCH_LIST; do

	echo "Building for arch $ARCH"
	export ARCH=$ARCH

	mkdir -p dist-$ARCH

	# Debian library
	[ -e dist-$ARCH/libandroid-shmem-disableselinux.so ] || {
		gcc -ffunction-sections -fdata-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -Wformat -Werror=format-security -Os -DNDEBUG -fPIC \
			-Iandroid-shmem -Iandroid-shmem/libancillary -D_LINUX_IPC_H -DNDEBUG \
			--shared -Wl,--version-script=disableselinux/exports.txt \
			android-shmem/*.c disableselinux/*.c \
			-Wl,--gc-sections -Wl,--build-id -Wl,--warn-shared-textrel -Wl,--fatal-warnings -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now \
			-lpthread \
			-o dist-$ARCH/libandroid-shmem-disableselinux.so &&
			strip dist-$ARCH/libandroid-shmem-disableselinux.so \
		|| fail
	} || fail

	continue

	# Android native library
	[ -e dist-$ARCH/libandroid-shmem-disableselinux.so ] || {
		env ARCH=$ARCH ./setCrossEnvironment-$ARCH.sh sh -c ' \
			$CC $CFLAGS -Iandroid-shmem -Iandroid-shmem/libancillary -D_LINUX_IPC_H -DNDEBUG \
			android-shmem/*.c disableselinux/*.c \
			--shared $LDFLAGS -Wl,--version-script=disableselinux/exports.txt \
			-o dist-$ARCH/libandroid-shmem-disableselinux.so &&
			$STRIP dist-$ARCH/libandroid-shmem-disableselinux.so \
		' || fail
	} || fail

	continue # Do not bother with this crap, grab precompiled proot from https://bintray.com/termux/termux-packages-24/proot

	[ -e dist-$ARCH/libdisableselinux.so ] || {
		gcc -fPIC -shared disableselinux/*.c $CFLAGS $LDFLAGS -o dist-$ARCH/libdisableselinux.so && \
			strip dist-$ARCH/libdisableselinux.so || fail
	} || fail

	[ -e dist-$ARCH/libandroid-shmem.so ] || {
		cd android-shmem
		make || fail
		cp -f libandroid-shmem-$ARCH.so ../dist-$ARCH/libandroid-shmem.so
		cd ..
	} || fail

	[ -e talloc-2.3.0.tar.gz ] || wget https://www.samba.org/ftp/talloc/talloc-2.3.0.tar.gz || fail

	[ -e libtalloc-$ARCH.a ] || {
		[ -e talloc-2.3.0 ] || tar xvzf talloc-2.3.0.tar.gz || fail
		cd talloc-2.3.0
		make clean
		../setCrossEnvironment-$ARCH.sh \
			./configure build --cross-compile --cross-answers=`pwd`/../talloc-cross-answers.txt \
			--without-gettext --disable-python || fail
		#env CC=arm-linux-gnueabihf-gcc CFLAGS="-flto -fpic" LD=arm-linux-gnueabihf-gcc LDFLAGS="-flto" ./configure build --cross-compile --cross-execute='qemu-arm-static /usr/arm-linux-gnueabihf/lib/ld-linux.so.3 --library-path /usr/arm-linux-gnueabihf/lib' || fail
		ar rcs ../libtalloc-$ARCH.a bin/default/talloc*.o
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

done
