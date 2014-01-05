#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mkdir /dev/pts
mount -t devpts none /dev/pts
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games
dhclient eth0

if false; then
cat >/etc/apt/sources.list <<EOF
deb http://ftp.ua.debian.org/debian/ wheezy contrib main non-free
deb-src http://ftp.ua.debian.org/debian/ wheezy main contrib

deb http://security.debian.org/ wheezy/updates contrib main non-free
deb-src http://security.debian.org/ wheezy/updates main contrib

deb http://ftp.ua.debian.org/debian/ wheezy-updates contrib main non-free
deb-src http://ftp.ua.debian.org/debian/ wheezy-updates main contrib

deb http://ftp.ua.debian.org/debian/ wheezy-backports contrib main non-free
deb-src http://ftp.ua.debian.org/debian/ wheezy-backports contrib main
EOF
fi

apt-get update
#apt-get install libreoffice
echo "Done! You may install additional packages using apt-get"
