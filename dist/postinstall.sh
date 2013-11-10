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

#./chroot.sh usr/sbin/groupadd -g $USER_ID $USER
#./chroot.sh usr/sbin/useradd -g $USER_ID -G sudo,staff -m $USER
./chroot.sh usr/sbin/useradd -U -m -G sudo,staff -p '$1$nFL/I4tz$zHKmBfkaKmRRmWje1Mupm0' -u $USER_ID $USER
./chroot.sh bin/cp -a -f root home/$USER
