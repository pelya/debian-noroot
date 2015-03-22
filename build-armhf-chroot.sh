#!/bin/sh

fail() { echo "Compilation failed!" ; exit 1; }

[ -e libtalloc.a ] || {
	[ -e talloc-2.1.0 ] || curl -L http://www.samba.org/ftp/talloc/talloc-2.1.0.tar.gz | tar xvz || fail
	cd talloc-2.1.0
	make clean
	env CFLAGS="-flto -fpic" LDFLAGS="-flto" ./configure build || fail
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
	env \
		CFLAGS="-I../../talloc-2.1.0 -Wall -Wextra -O2 -flto -fpic -I../../linux-includes" \
		LDFLAGS="-L../.. -ltalloc -static -flto" \
		V=1 make -e -j4 || fail
	cp proot ../../dist/
	cd ../..
	strip dist/proot
} || fail
