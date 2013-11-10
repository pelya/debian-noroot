#!/system/bin/sh

case x$SDCARD in x ) export SDCARD=$EXTERNAL_STORAGE;; esac
echo "SDCARD path: $SDCARD"
echo "Changing curdir to: $SECURE_STORAGE_DIR"
case x$SECURE_STORAGE_DIR in x ) echo ... > /dev/null;; * ) cd $SECURE_STORAGE_DIR;; esac

ln -sf $SDCARD sdcard

echo "Creating necessary directories"
# Random post-install cmds
mkdir -p var/run/dbus
mkdir -p var/run/xauth
ln -sf `pwd`/usr/bin/dbus-launch `pwd`/bin/dbus-launch
mkdir -p var/lib/dbus
mkdir -p root
mkdir -p root/Desktop
ln -sf $SDCARD root/sdcard
ln -sf $SDCARD root/Desktop/sdcard

echo "Updating lib paths"
./updatelibpaths.sh > libpaths

ls lib/ld-linux-armel.so.3 && ln -s ld-linux-armhf.so.3 lib/ld-linux.so.3
ls lib/ld-linux-armhf.so.3 && ln -s ld-linux-armhf.so.3 lib/ld-linux.so.3

echo "Adding user $USER ID $USER_ID"
./chroot.sh bin/bash usr/bin/fakeroot-sysv usr/sbin/useradd -U -m -G sudo,staff -p '$1$nFL/I4tz$zHKmBfkaKmRRmWje1Mupm0' -u $USER_ID $USER 2>&1
./chroot.sh bin/cp -a -f root/* root/.* home/$USER/ 2>&1

echo "Postinstall script finished"
