#!/bin/sh

ARCH="`dpkg --print-architecture`"
#ARCH=armhf
#ARCH=i386
[ -z "$ARCH" ] && {
	echo "ARCH not defined!"
	exit 1
}

rm -rf $ARCH
mkdir -p $ARCH
cd $ARCH
apt-get source gimp libgc1c2 || exit 1
cd libgc-7.2d
patch -p1 < ../../libgc-disable-dev-zero.patch || exit 1
env DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -us -uc -j4 || exit 1
cd ..
cd gimp-2.8.14 || exit 1
patch -p1 < ../../gimp-limit-redraw-rate.patch || exit 1
dpkg-buildpackage -us -uc -b -j4 || exit 1
cd ..
cd ..
