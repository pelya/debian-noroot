#!/bin/sh
echo "Ubuntu Natty is the last Ubuntu supporting 2.6.X kernel - Precise will not work on many devices, because it requires kernel 3.0.X"
sudo rm -r -f dist-minimal
sudo qemu-debootstrap --arch=armel --verbose \
        --components=main,universe,restricted,multiverse \
        --include=ubuntu-minimal,xfce4-panel,xfce4-session,xfce4-utils,xfdesktop4,fakeroot,fakechroot,tightvncserver,synaptic \
        natty dist-minimal \
&& sudo ./prepare-img.sh dist-minimal com.cuntubuntu
