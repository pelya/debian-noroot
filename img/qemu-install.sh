#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mkdir /dev/pts
mount -t devpts none /dev/pts
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games
dhclient eth0
echo "deb http://archive.debian.org/debian lenny main contrib" > /etc/apt/sources.list
echo "deb http://archive.debian.org/debian-security lenny/updates main contrib" >> /etc/apt/sources.list
apt-get update
apt-get install xfonts-base tightvncserver synaptic socat putty xfce4-panel xfce4-session xfce4-utils xfdesktop4 xfwm4 gimp
echo "Done! You may install additional packages using apt-get"
