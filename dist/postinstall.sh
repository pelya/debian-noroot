#!/system/bin/sh

case x$SDCARD in x ) export SDCARD=$EXTERNAL_STORAGE;; esac

cat $SDCARD/download/busybox > busybox
chmod 755 busybox
./busybox tar xzvf $SDCARD/download/ubuntu.tar.gz
cat $SDCARD/download/fixsymlinks.sh > fixsymlinks.sh
chmod 755 fixsymlinks.sh
./busybox sh ./fixsymlinks.sh
cat $SDCARD/download/libfakechroot.so > libfakechroot.so
chmod 755 libfakechroot.so
cat $SDCARD/download/libfakedns.so > libfakedns.so
chmod 755 libfakedns.so
# Random post-install cmds
mkdir run/dbus
mkdir run/xauth
mkdir sdcard
mkdir root
mkdir root/.vnc
cat $SDCARD/download/passwd > root/.vnc/passwd
mkdir root/Desktop
cat $SDCARD/download/Synaptic.desktop > root/Desktop/Synaptic.desktop
chmod 644 root/Desktop/Synaptic.desktop
ln -s `pwd`/usr/bin/dbus-launch `pwd`/bin/dbus-launch
echo nameserver 8.8.8.8 > etc/resolv.conf
echo nameserver 8.8.4.4 >> etc/resolv.conf

cat $SDCARD/download/startx.sh > startx.sh
chmod 755 startx.sh

cat $SDCARD/download/chroot.sh > chroot.sh
chmod 755 chroot.sh

rm $SDCARD/download/ubuntu.tar.gz
