#!/bin/sh
echo "This image requires kernel 2.6.29, it will run on emulator"
DIR=dist-debug-wheezy-proot/img
sudo rm -r -f $DIR
APT_CACHER=
[ -e /etc/init.d/apt-cacher ] && APT_CACHER=/localhost:3142
sudo qemu-debootstrap --arch=armhf --verbose \
        --components=main,universe,restricted,multiverse \
        --include=fakeroot,fakechroot,xfonts-base,x11-xserver-utils,xfce4-panel,xfdesktop4,xfwm4,xfce4-session,thunar,xfconf,xfce4-settings,tango-icon-theme,shiki-colors-xfwm-theme,strace,gdb,apt,synaptic,apt-xapian-index \
        wheezy $DIR http:/$APT_CACHER/ftp.ua.debian.org/debian/ \
&& cat sources-jessie.list | sed 's/jessie/wheezy/g' | sudo tee $DIR/etc/apt/sources.list > /dev/null \
&& sudo ./prepare-img-proot.sh $DIR
