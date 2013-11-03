#!/bin/sh
echo "Minimum kernel is 2.6.32, it should be fine for emulator"
# libreoffice-calc,libreoffice-draw,libreoffice-impress,libreoffice-math,libreoffice-writer,xfce4
sudo rm -r -f dist-debug-squeeze
APT_CACHER=
[ -e /etc/init.d/apt-cacher ] && APT_CACHER=/localhost:3142
sudo qemu-debootstrap --arch=armel --verbose \
        --components=main,universe,restricted,multiverse \
        --include=base-files,fakeroot,fakechroot,xfonts-base,strace,synaptic,gimp \
        squeeze dist-debug-squeeze http:/$APT_CACHER/ftp.ua.debian.org/debian/ \
&& sudo cp -a dist-debug-squeeze dist-debug-squeeze-back && sudo ./prepare-img.sh dist-debug-squeeze /data/local/tmp/img
