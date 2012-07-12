#!/bin/sh
echo "Ubuntu Precise requires 3.0.0 or newer kernel"
sudo rm -r -f dist-gimp-precise
sudo qemu-debootstrap --arch=armel --verbose \
        --components=main,universe,restricted,multiverse \
        --include=ubuntu-minimal,fakeroot,fakechroot,xfonts-base,x11-common,tightvncserver,synaptic,busybox-static,putty,xfce4-panel,xfce4-session,xfce4-utils,xfdesktop4,xfwm4,gimp \
        precise dist-gimp-precise \
&& sudo ./prepare-img.sh dist-gimp-precise /data/data/com.cuntubuntu/files
