#!/bin/sh
echo "Ubuntu Precise requires 3.0.0 or newer kernel"
sudo rm -r -f dist-gimp-precise
sudo qemu-debootstrap --arch=armel --verbose \
        --components=main,universe,restricted,multiverse \
        --include=ubuntu-minimal,fakeroot,fakechroot,xfonts-base,tightvncserver,synaptic,socat,putty,xfce4-panel,xfce4-session,xfce4-utils,xfdesktop4,xfwm4,thunar,gimp \
        precise dist-gimp-precise \
&& sudo sh -c "echo deb http://ports.ubuntu.com/ precise main restricted universe multiverse >> dist-gimp-precise/etc/apt/sources.list" \
&& sudo sh -c "echo deb http://ports.ubuntu.com/ precise-updates main restricted universe multiverse >> dist-gimp-precise/etc/apt/sources.list" \
&& sudo sh -c "echo deb http://ports.ubuntu.com/ precise-security main restricted universe multiverse >> dist-gimp-precise/etc/apt/sources.list" \
&& sudo ./prepare-img.sh dist-gimp-precise /data/data/com.cuntubuntu/files
