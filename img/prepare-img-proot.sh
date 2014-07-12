#!/bin/sh
[ "$USER" = "root" ] || { echo This script needs to be run with superuser privileges; exit 1; }

set -x

UPDATE_PACKAGES=false
if [ "$1" = "--update-packages" ]; then
	UPDATE_PACKAGES=true
	shift
fi

SAVE_PACKAGES_LIST=false
if [ "$1" = "--save-packages-list" ]; then
	SAVE_PACKAGES_LIST=true
	shift
fi

STRIP=false
STRIP_FILES=""
if [ "$1" = "--strip" ]; then
	STRIP=true
	shift
	STRIP_FILES="$1"
	shift
fi

XZ=false
if [ "$1" = "--xz" ]; then
	XZ=true
	shift
fi

NOARCHIVE=false
if [ "$1" = "--noarchive" ]; then
	NOARCHIVE=true
	shift
fi

DIST=dist-minimal

[ -z "$1" ] || DIST="$1"

ARCH="$2"

CURDIR=`pwd`

cd $DIST

cat $CURDIR/sources-jessie.list | sed 's/jessie/wheezy/g' | tee etc/apt/sources.list > /dev/null

CHROOT_CMD="qemu-arm-static lib/ld-linux-armhf.so.3 --library-path lib/arm-linux-gnueabihf usr/sbin/chroot ."
[ "$ARCH" = "x86" ] && CHROOT_CMD="chroot ."

$UPDATE_PACKAGES && {
	$CHROOT_CMD usr/bin/apt-get update
	$CHROOT_CMD usr/bin/apt-get upgrade -y
}

$SAVE_PACKAGES_LIST && {
	$CHROOT_CMD usr/sbin/update-apt-xapian-index
}

$CHROOT_CMD usr/sbin/update-alternatives --set fakeroot /usr/bin/fakeroot-tcp

rm -f var/cache/apt/archives/*.deb
rm -f var/log/bootstrap.log

$SAVE_PACKAGES_LIST || {
	rm -f var/cache/apt/*.bin
	find var/lib/apt/lists/ -type f -delete
	cp -a /var/lib/apt/lists/lock var/lib/apt/lists/
}

$STRIP && {
	#$CHROOT_CMD apt-get remove -y `cat $CURDIR/strip.list`
	find var/log -type f -delete
	rm -rf usr/share/locale/*
	rm -rf usr/share/doc/*
	rm -rf usr/share/man/*
	rm -rf usr/share/info/*
	rm -rf var/cache/debconf/*
	rm -rf var/cache/apt/*.bin
	rm -rf $STRIP_FILES
}

cp -a $CURDIR/../dist/* .
[ -z "$ARCH" ] || cp -a -f $CURDIR/../dist-$ARCH/* .

$NOARCHIVE && exit

ARCHIVE=`echo $DIST | sed 's@/.*@@'`
cd $CURDIR/$ARCHIVE
if $XZ; then
	tar c * | pxz -8 > ../$ARCHIVE.tar.xz
else
	tar czf ../$ARCHIVE.tar.gz *
fi
