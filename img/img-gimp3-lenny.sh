#!/bin/sh
echo "This should run on emulator with kernel 2.6.29"
echo "TODO: this command FAILS for no reason!"
DIST=lenny
VARIANT=gimp3
sudo rm -r -f dist-$VARIANT-$DIST
sudo qemu-debootstrap --arch=armel --verbose \
        --components=main,contrib \
        --include=fakeroot,fakechroot,xfonts-base \
        $DIST dist-$VARIANT-$DIST http://archive.debian.org/debian \

#&& sudo ./prepare-img.sh dist-$VARIANT-$DIST /data/data/com.cuntubuntu/files
