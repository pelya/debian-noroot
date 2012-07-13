#!/bin/sh
echo "This should run on emulator with kernel 2.6.29"
DIST=lucid
sudo rm -r -f dist-gimp-$DIST
sudo qemu-debootstrap --arch=armel --verbose \
        --components=main,universe,restricted,multiverse \
        --include=ubuntu-minimal,fakeroot,fakechroot,xfonts-base,x11-common,tightvncserver,synaptic,busybox-static,putty,xfce4-panel,xfce4-session,xfce4-utils,xfdesktop4,xfwm4,gimp \
        $DIST dist-gimp-$DIST \
&& sudo ./prepare-img.sh dist-gimp-$DIST /data/data/com.cuntubuntu/files
