#!/bin/sh
DIR=wheezy-armhf

[ -e $DIR ] || {
APT_CACHER=
[ -e /etc/init.d/apt-cacher ] && APT_CACHER=/localhost:3142
sudo qemu-debootstrap --arch=armhf --verbose \
        --components=main,universe,restricted,multiverse \
        --include=fakeroot,fakechroot,xfonts-base,x11-xserver-utils,xfce4-panel,xfdesktop4,xfwm4,xfce4-session,thunar,xfconf,xfce4-settings,tango-icon-theme,gimp,inkscape,build-essential \
        wheezy $DIR http:/$APT_CACHER/ftp.ua.debian.org/debian/ \
&& cat sources-jessie.list | sed 's/jessie/wheezy/g' | sudo tee $DIR/etc/apt/sources.list > /dev/null
}

echo "Now run:"
echo "apt-get update"
echo "apt-get build-dep gimp"
sudo chroot $DIR bin/bash -l
