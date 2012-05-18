#!/bin/sh
echo "You need to cross-compile both libfakechroot.so and libfakedns.so using Ubuntu Natty, or older"
sudo debootstrap --verbose \
        --components=main,universe,restricted,multiverse \
        --include=ubuntu-minimal,build-essential,g++-arm-linux-gnueabi,make,autoconf,automake \
        natty buildenv http://ua.archive.ubuntu.com/ubuntu
echo "Easiest way for compiling is to use schroot: sudo apt-get install schroot'
