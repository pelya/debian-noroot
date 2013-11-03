#!/system/bin/sh

case x$SDCARD_UBUNTU in x ) export SDCARD_UBUNTU=$EXTERNAL_STORAGE/ubuntu;; esac
case x$SDCARD_ROOT in x ) export SDCARD_ROOT=$EXTERNAL_STORAGE;; esac

ls $SDCARD_UBUNTU/busybox && cat $SDCARD_UBUNTU/busybox > busybox
chmod 755 busybox
./busybox tar xzvf $SDCARD_UBUNTU/binaries.tar.gz

ls $SDCARD_UBUNTU/libfakechroot.so && cat $SDCARD_UBUNTU/libfakechroot.so > libfakechroot.so
chmod 755 libfakechroot.so

ls $SDCARD_UBUNTU/libfakedns.so && cat $SDCARD_UBUNTU/libfakedns.so > libfakedns.so
chmod 755 libfakedns.so

rm -r sd
ln -s $SDCARD_UBUNTU sd
ln -s $SDCARD_ROOT sdcard

ls $SDCARD_UBUNTU/startx.sh && cat $SDCARD_UBUNTU/startx.sh > startx.sh
chmod 755 startx.sh

ls $SDCARD_UBUNTU/fakeroot.sh && cat $SDCARD_UBUNTU/fakeroot.sh > fakeroot.sh
chmod 755 fakeroot.sh

ls $SDCARD_UBUNTU/xterm.sh && cat $SDCARD_UBUNTU/xterm.sh > xterm.sh
chmod 755 xterm.sh

echo nameserver 8.8.8.8 > etc/resolv.conf
echo nameserver 8.8.4.4 >> etc/resolv.conf

echo 127.0.0.1	localhost >> etc/hosts
echo 127.0.0.1	ubuntu >> etc/hosts

echo ubuntu >> etc/hostname

# Random post-install cmds
mkdir var/run/dbus
mkdir var/run/xauth
ln -s `pwd`/usr/bin/dbus-launch `pwd`/bin/dbus-launch
mkdir var/lib/dbus
cat $SDCARD_UBUNTU/machine-id > var/lib/dbus/machine-id
chmod 644 var/lib/dbus/machine-id
mkdir root
mkdir root/.vnc
cat $SDCARD_UBUNTU/passwd > root/.vnc/passwd
mkdir root/Desktop
for D in $SDCARD_UBUNTU/*.desktop; do
cat $D > root/Desktop/`./busybox basename $D`
chmod 644 root/Desktop/`./busybox basename $D`
done
ln -s $SDCARD_ROOT root/sdcard
ln -s $SDCARD_ROOT root/Desktop/sdcard

ls $SDCARD_UBUNTU/updatelibpaths.sh && cat $SDCARD_UBUNTU/updatelibpaths.sh > updatelibpaths.sh
chmod 755 updatelibpaths.sh
./updatelibpaths.sh > libpaths

ls lib/ld-linux-armel.so.3 && ln -s ld-linux-armhf.so.3 lib/ld-linux.so.3
ls lib/ld-linux-armhf.so.3 && ln -s ld-linux-armhf.so.3 lib/ld-linux.so.3

# This one should come last
ls $SDCARD_UBUNTU/chroot.sh && cat $SDCARD_UBUNTU/chroot.sh > chroot.sh
chmod 755 chroot.sh

rm $SDCARD_UBUNTU/binaries.tar.gz
