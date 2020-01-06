#!/bin/sh

set +x

CURDIR=`pwd`

DIST=dist-debian-buster

for ARCH in x86_64 arm64-v8a; do

	rm -rf overlay || exit 1
	mkdir -p overlay/img || exit 1
	cd overlay/img

	cp -a $CURDIR/../dist/* .
	cp -a -f $CURDIR/../dist-$ARCH/* .

	cd $CURDIR/$DIST-$ARCH
	find img -type l > $CURDIR/$DIST-symlinks-$ARCH.txt
	tar c -T $CURDIR/$DIST-symlinks-$ARCH.txt | xz -8 > $CURDIR/$DIST-symlinks-$ARCH.tar.xz
	cd $CURDIR/overlay/img

	ARCHIVE=$DIST-overlay-$ARCH
	cd ..
	tar c * | xz -8 > $CURDIR/$ARCHIVE.tar.xz

	cd $CURDIR

	[ -d $CURDIR/../../AndroidData ] && {
		cp -f $CURDIR/$ARCHIVE.tar.xz $CURDIR/../../AndroidData/overlay-$ARCH.tar.xz
		cp -f $CURDIR/$DIST-symlinks-$ARCH.tar.xz $CURDIR/../../AndroidData/symlinks-$ARCH.tar.xz
	}
done

rm -rf overlay
