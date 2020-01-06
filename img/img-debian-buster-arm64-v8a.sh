#!/bin/sh

DIR=dist-debian-buster-arm64-v8a/img
CHROOT="qemu-aarch64-static $DIR/lib/ld-linux-aarch64.so.1 --library-path $DIR/lib/aarch64-linux-gnu $DIR/usr/sbin/chroot $DIR"
sudo rm -r -f $DIR
mkdir -p $DIR
APT_CACHER=
[ -e /etc/init.d/apt-cacher ] && APT_CACHER=/localhost:3142
[ -e /etc/init.d/apt-cacher-ng ] && APT_CACHER=/localhost:3142
sudo qemu-debootstrap --arch=arm64 --verbose \
        --components=main,contrib,non-free \
        buster $DIR http:/$APT_CACHER/ftp.de.debian.org/debian/ \
&& cat sources-jessie.list | sed 's/jessie/buster/g' | sudo tee $DIR/etc/apt/sources.list > /dev/null \
&& sudo $CHROOT apt-get update \
&& sudo $CHROOT apt-get install -y `cat img-debian-buster.pkg` \
&& sudo ./prepare-img-proot.sh --xz $DIR arm64-v8a
