#!/system/bin/sh

case x$SDCARD_UBUNTU in x ) export SDCARD_UBUNTU=$EXTERNAL_STORAGE/ubuntu;; esac

cat $SDCARD_UBUNTU/busybox > busybox
chmod 755 busybox
./busybox tar xzvf $SDCARD_UBUNTU/binaries.tar.gz

cat $SDCARD_UBUNTU/libfakechroot.so > libfakechroot.so
chmod 755 libfakechroot.so

cat $SDCARD_UBUNTU/libfakedns.so > libfakedns.so
chmod 755 libfakedns.so

rm -r sd
ln -s $SDCARD_UBUNTU sd
ln -s $SDCARD_ROOT sdcard

cat $SDCARD_UBUNTU/startx.sh > startx.sh
chmod 755 startx.sh

cat $SDCARD_UBUNTU/chroot.sh > chroot.sh
chmod 755 chroot.sh

echo nameserver 8.8.8.8 > etc/resolv.conf
echo nameserver 8.8.4.4 >> etc/resolv.conf

# Random post-install cmds
mkdir var/run/dbus
mkdir var/run/xauth
mkdir root
mkdir root/.vnc
cat $SDCARD_UBUNTU/passwd > root/.vnc/passwd
mkdir root/Desktop
cat $SDCARD_UBUNTU/Synaptic.desktop > root/Desktop/Synaptic.desktop
chmod 644 root/Desktop/Synaptic.desktop
cat $SDCARD_UBUNTU/New%20shortcut.desktop > root/Desktop/New%20shortcut.desktop
chmod 644 root/Desktop/New%20shortcut.desktop
ln -s `pwd`/usr/bin/dbus-launch `pwd`/bin/dbus-launch
ls usr/bin/libreoffice && cat $SDCARD_UBUNTU/Office.desktop > root/Desktop/Office.desktop && chmod 644 root/Desktop/Office.desktop

rm $SDCARD_UBUNTU/binaries.tar.gz
