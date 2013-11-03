#!/bin/sh
echo "This image requires kernel 3.10, it will NOT run on ANY emulator"
# libreoffice-calc,libreoffice-draw,libreoffice-impress,libreoffice-math,libreoffice-writer
sudo rm -r -f dist-debug-jessie
APT_CACHER=
[ -e /etc/init.d/apt-cacher ] && APT_CACHER=/localhost:3142
sudo qemu-debootstrap --arch=armhf --verbose \
        --components=main,universe,restricted,multiverse \
        --include=base-files,fakeroot,fakechroot,xfonts-base,strace,synaptic,socat,putty,xfce4,gimp \
        jessie dist-debug-jessie http:/$APT_CACHER/ftp.ua.debian.org/debian/ \
&& sudo cp -a dist-debug-jessie dist-debug-jessie-back && sudo ./prepare-img.sh dist-debug-jessie /data/local/tmp/img
