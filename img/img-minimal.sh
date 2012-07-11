#!/bin/sh
echo "Ubuntu Natty is the last Ubuntu supporting 2.6.X kernel - Precise will not work on many devices, because it requires kernel 3.0.X"
sudo rm -r -f dist-minimal
sudo qemu-debootstrap --arch=armel --verbose \
        --components=main,universe,restricted,multiverse \
        --include=ubuntu-minimal,fakeroot,fakechroot,xfonts-base,x11-common,tightvncserver,synaptic,busybox,putty,xfce4-panel,xfce4-session,xfce4-utils,xfdesktop4,xfwm4 \
        natty dist-minimal \
&& sudo ./prepare-img.sh dist-minimal /data/data/com.cuntubuntu/files
