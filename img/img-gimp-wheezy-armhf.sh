#!/bin/sh

DIR=dist-gimp-wheezy-armeabi-v7a/img
sudo rm -r -f $DIR
mkdir -p $DIR
APT_CACHER=
[ -e /etc/init.d/apt-cacher ] && APT_CACHER=/localhost:3142
sudo qemu-debootstrap --arch=armhf --verbose \
        --components=main,universe,restricted,multiverse \
        --include=`cat img-gimp-wheezy.pkg` \
        wheezy $DIR http:/$APT_CACHER/ftp.ua.debian.org/debian/ \
&& cat sources-jessie.list | sed 's/jessie/wheezy/g' | sudo tee $DIR/etc/apt/sources.list > /dev/null \
&& sudo ./prepare-img-proot.sh --update-packages $DIR
