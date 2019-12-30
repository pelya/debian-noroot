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

	ARCHIVE=$DIST-overlay-$ARCH
	tar c * | xz -8 > $CURDIR/$ARCHIVE.tar.xz

	cd $CURDIR

done

rm -rf overlay
