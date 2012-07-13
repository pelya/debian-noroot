#!/bin/sh
echo "This should run on emulator with kernel 2.6.29"
echo "TODO: this command FAILS for no reason! Even inside qemu!"
DIST=lenny
VARIANT=gimp
sudo rm -r -f dist-$VARIANT-$DIST
sudo debootstrap --arch=armel --verbose --foreign \
        --components=main,contrib \
        --include=libc6,fakeroot,fakechroot,apt,busybox-static,xfonts-base,x11-common,tightvncserver,synaptic,putty,xfce4-panel,xfce4-session,xfce4-utils,xfdesktop4,xfwm4,gimp \
        $DIST dist-$VARIANT-$DIST http://archive.debian.org/debian
echo "Base system downloaded into dist-$VARIANT-$DIST, now run img-$VARIANT-$DIST-stage2.sh"
