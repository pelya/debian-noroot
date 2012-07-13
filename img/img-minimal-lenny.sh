#!/bin/sh
echo "This should run on emulator with kernel 2.6.29"
DIST=lenny
VARIANT=minimal
sudo rm -r -f dist-$VARIANT-$DIST
sudo qemu-debootstrap --arch=armel --verbose \
        --components=main,contrib \
        --include=libc6,fakeroot,fakechroot,apt,busybox-static \
        $DIST dist-$VARIANT-$DIST http://archive.debian.org/debian \
&& sudo ./prepare-img.sh dist-$VARIANT-$DIST /data/data/com.cuntubuntu/files
