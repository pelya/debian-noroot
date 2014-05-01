#!/bin/sh
[ "$USER" = "root" ] || { echo This script needs to be run with superuser privileges; exit 1; }

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
#find var/log -type f -delete

$SAVE_PACKAGES_LIST || {
	rm -f var/cache/apt/*.bin
}

cp -a $CURDIR/../dist/* .
[ -z "$ARCH" ] || cp -a -f $CURDIR/../dist-$ARCH/* .

ARCHIVE=`echo $DIST | sed 's@/.*@@'`
cd $CURDIR/$ARCHIVE
tar czf ../$ARCHIVE.tar.gz *
