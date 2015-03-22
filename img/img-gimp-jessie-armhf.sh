#!/bin/sh

DIR=dist-gimp-jessie-armeabi-v7a/img
sudo rm -r -f $DIR
mkdir -p $DIR
APT_CACHER=
[ -e /etc/init.d/apt-cacher ] && APT_CACHER=/localhost:3142
sudo qemu-debootstrap --arch=armhf --verbose \
        --components=main,contrib,non-free \
        --include=`cat img-gimp-wheezy.pkg` \
        jessie $DIR http:/$APT_CACHER/ftp.de.debian.org/debian/ \
&& cat sources-jessie.list | sudo tee $DIR/etc/apt/sources.list > /dev/null \
&& sudo ./prepare-img-proot.sh --update-packages $DIR