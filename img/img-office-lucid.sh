#!/bin/sh
echo "This should run on devices with kernel 2.6.32"
DIST=lucid
sudo rm -r -f dist-office-$DIST
sudo qemu-debootstrap --arch=armel --verbose \
        --components=main,universe,restricted,multiverse \
        --include=ubuntu-minimal,fakeroot,fakechroot,xfonts-base,x11-common,tightvncserver,synaptic,busybox-static,putty,xfce4-panel,xfce4-session,xfce4-utils,xfdesktop4,xfwm4,gimp,abiword,gnumeric \
        $DIST dist-office-$DIST \
&& sudo ./prepare-img.sh dist-office-$DIST /data/data/com.cuntubuntu/files
