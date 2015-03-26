#!/bin/sh

DIR=dist-gimp-jessie-armeabi-v7a/img
CHROOT="qemu-arm-static $DIR/lib/ld-linux-armhf.so.3 --library-path $DIR/lib/arm-linux-gnueabihf $DIR/usr/sbin/chroot $DIR"
sudo rm -r -f $DIR
mkdir -p $DIR
APT_CACHER=
[ -e /etc/init.d/apt-cacher ] && APT_CACHER=/localhost:3142
sudo qemu-debootstrap --arch=armhf --verbose \
        --components=main,contrib,non-free \
        jessie $DIR http:/$APT_CACHER/ftp.de.debian.org/debian/ \
&& cat sources-jessie.list | sudo tee $DIR/etc/apt/sources.list > /dev/null \
&& sudo $CHROOT apt-get update \
&& sudo $CHROOT apt-get upgrade -y \
&& sudo $CHROOT apt-get install -y `cat img-gimp-wheezy.pkg | sed 's/,/ /g'` \
&& sudo cp ../pkgs/*_armhf.deb $DIR \
&& sudo $CHROOT sh -c "dpkg -i *_armhf.deb" \
&& sudo rm $DIR/*_armhf.deb \
&& sudo ./prepare-img-proot.sh $DIR
