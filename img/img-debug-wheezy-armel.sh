#!/bin/sh
echo "This image requires kernel 2.6.29, it will run on emulator"
DIR=dist-debug-wheezy
sudo rm -r -f $DIR
APT_CACHER=
[ -e /etc/init.d/apt-cacher ] && APT_CACHER=/localhost:3142
sudo qemu-debootstrap --arch=armel --verbose \
        --components=main,universe,restricted,multiverse \
        --include=fakeroot,fakechroot,bash \
        wheezy $DIR http:/$APT_CACHER/ftp.ua.debian.org/debian/ \
&& cat sources-jessie.list | sed 's/jessie/wheezy/g' | sudo tee $DIR/etc/apt/sources.list > /dev/null \
&& sudo cp -a $DIR $DIR-back && sudo ./prepare-img.sh $DIR /data/local/tmp/img
