#!/system/bin/sh

case x$SDCARD in x ) export SDCARD=$EXTERNAL_STORAGE;; esac

case x$SECURE_STORAGE_DIR in x ) echo ...;; * ) cd $SECURE_STORAGE_DIR;; esac

ln -s $SDCARD sdcard

# Random post-install cmds
mkdir var/run/dbus
mkdir var/run/xauth
ln -s `pwd`/usr/bin/dbus-launch `pwd`/bin/dbus-launch
mkdir var/lib/dbus
mkdir root
mkdir root/Desktop
chmod 644 root/Desktop/*
ln -s $SDCARD root/sdcard
ln -s $SDCARD root/Desktop/sdcard

./updatelibpaths.sh > libpaths

ls lib/ld-linux-armel.so.3 && ln -s ld-linux-armhf.so.3 lib/ld-linux.so.3
ls lib/ld-linux-armhf.so.3 && ln -s ld-linux-armhf.so.3 lib/ld-linux.so.3
