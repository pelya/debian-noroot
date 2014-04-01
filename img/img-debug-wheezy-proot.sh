#!/bin/sh
DIR=dist-debug-wheezy-proot-armeabi-v7a/img
sudo rm -r -f $DIR
mkdir -p $DIR
APT_CACHER=
[ -e /etc/init.d/apt-cacher ] && APT_CACHER=/localhost:3142
sudo qemu-debootstrap --arch=armhf --verbose \
        --components=main,universe,restricted,multiverse \
        --include=fakeroot,fakechroot,libc-bin,dpkg,xfonts-base,x11-xserver-utils,xfce4-panel,xfdesktop4,xfwm4,xfce4-session,thunar,xfconf,xfce4-settings,tango-icon-theme,apt,synaptic,apt-xapian-index,xterm,locales \
        wheezy $DIR http:/$APT_CACHER/ftp.ua.debian.org/debian/ \
&& sudo ./prepare-img-proot.sh $DIR
