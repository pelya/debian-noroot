#!/bin/sh

DIR=dist-cups-wheezy-armeabi-v7a/img
sudo rm -r -f $DIR
mkdir -p $DIR
APT_CACHER=
[ -e /etc/init.d/apt-cacher ] && APT_CACHER=/localhost:3142
sudo qemu-debootstrap --arch=armhf --verbose \
        --components=main,contrib,non-free \
        --include=fakeroot,libc-bin,cups,apt,smbclient \
        wheezy $DIR http:/$APT_CACHER/ftp.ua.debian.org/debian/ \
&& cat sources-wheezy.list | sudo tee $DIR/etc/apt/sources.list > /dev/null \
&& sudo ./prepare-img-proot.sh --strip "usr/share/X11 usr/share/zoneinfo" $DIR
