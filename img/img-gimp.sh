#!/bin/sh
echo "Ubuntu Natty is the last Ubuntu supporting 2.6.X kernel - Precise will not work on many devices, because it requires kernel 3.0.X"
echo "This image includes only GIMP, on a barebone X server, you won't be able to install packages"
sudo rm -r -f dist-gimp
sudo qemu-debootstrap --arch=armel --verbose \
        --components=main,universe,restricted,multiverse \
        --include=fakeroot,fakechroot,tightvncserver,gimp \
        natty dist-gimp \
&& sudo ./prepare-img.sh dist-gimp org.gimp
