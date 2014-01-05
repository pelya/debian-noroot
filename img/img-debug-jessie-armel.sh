#!/bin/sh
echo "This image requires kernel 3.10, it will NOT run on ANY emulator"
# libreoffice-calc,libreoffice-draw,libreoffice-impress,libreoffice-math,libreoffice-writer
DIR=dist-debug-jessie
sudo rm -r -f $DIR
APT_CACHER=
[ -e /etc/init.d/apt-cacher ] && APT_CACHER=/localhost:3142
sudo qemu-debootstrap --arch=armel --verbose \
        --components=main,universe,restricted,multiverse \
        --include=base-files,fakeroot,fakechroot,xfonts-base,strace,synaptic,socat,putty,xfce4,metacity,razorqt,openbox,fluxbox,fbpager,gimp,inkscape \
        jessie $DIR http:/$APT_CACHER/ftp.ua.debian.org/debian/ \
&& cat sources-jessie.list | sudo tee $DIR/etc/apt/sources.list > /dev/null \
&& sudo cp -a $DIR $DIR-back && sudo ./prepare-img.sh $DIR /data/local/tmp/img
