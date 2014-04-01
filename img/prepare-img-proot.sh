#!/bin/sh
[ "$USER" = "root" ] || { echo This script needs to be run with superuser privileges; exit 1; }

DIST=dist-minimal

[ -z "$1" ] || DIST="$1"

ARCH="$2"

CURDIR=`pwd`

cd $DIST

cat $CURDIR/sources-jessie.list | sed 's/jessie/wheezy/g' | tee etc/apt/sources.list > /dev/null

qemu-arm-static lib/ld-linux-armhf.so.3 --library-path lib/arm-linux-gnueabihf usr/sbin/chroot . usr/bin/apt-get update
qemu-arm-static lib/ld-linux-armhf.so.3 --library-path lib/arm-linux-gnueabihf usr/sbin/chroot . usr/bin/apt-get upgrade -y
qemu-arm-static lib/ld-linux-armhf.so.3 --library-path lib/arm-linux-gnueabihf usr/sbin/chroot . usr/sbin/update-apt-xapian-index
qemu-arm-static lib/ld-linux-armhf.so.3 --library-path lib/arm-linux-gnueabihf usr/sbin/chroot . usr/sbin/update-alternatives --set fakeroot /usr/bin/fakeroot-tcp

rm -f var/cache/apt/archives/*.deb
#find var/log -type f -delete

cp -a $CURDIR/../dist/* .
[ -z "$ARCH" ] || cp -a -f $CURDIR/../dist-$ARCH/* .

ARCHIVE=`echo $DIST | sed 's@/.*@@'`
cd $CURDIR/$ARCHIVE
tar czf ../$ARCHIVE.tar.gz *
