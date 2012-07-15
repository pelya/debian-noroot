#!/bin/sh
echo "You need to cross-compile both libfakechroot.so and libfakedns.so using Debian Lenny, if you want it to be compatible with ARMEABI arch without floating point support"
sudo debootstrap --verbose \
        --components=main,universe,restricted,multiverse \
        --include=build-essential,make,autoconf,automake \
        lenny buildenv http://archive.debian.org/debian
sudo sh -c "echo deb http://www.emdebian.org/debian/ lenny main >> buildenv/etc/apt/sources.list"
sudo sh -c "echo deb http://archive.debian.org/debian/ lenny main contrib >> buildenv/etc/apt/sources.list"
sudo sh -c "echo apt-get install emdebian-archive-keyring >> buildenv/install-deps.sh"
sudo sh -c "echo apt-get update >> buildenv/install-deps.sh"
sudo sh -c "echo apt-get install linux-libc-dev-armel-cross libc6-armel-cross libc6-dev-armel-cross binutils-arm-linux-gnueabi gcc-4.3-arm-linux-gnueabi g++-4.3-arm-linux-gnueabi gdb-arm-linux-gnueabi uboot-mkimage >> buildenv/install-deps.sh"
sudo sh -c "chmod 755 buildenv/install-deps.sh"

echo "Easiest way for compiling is to use schroot: sudo apt-get install schroot, edit /etc/schroot/schroot.conf, and run it"
echo "then run ./install-deps.sh"
