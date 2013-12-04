#!/system/bin/sh

case x$SDCARD in x ) export SDCARD=$EXTERNAL_STORAGE;; esac
echo "SDCARD path: $SDCARD"
echo "Changing curdir to: $SECURE_STORAGE_DIR"
case x$SECURE_STORAGE_DIR in x ) echo ... > /dev/null;; * ) cd $SECURE_STORAGE_DIR;; esac

umask 002

ln -s $SDCARD sdcard

echo "Creating necessary directories"
# Random post-install cmds
mkdir var/run/dbus
mkdir var/run/xauth
ln -s `pwd`/usr/bin/dbus-launch `pwd`/bin/dbus-launch
mkdir var/lib/dbus
mkdir root
mkdir root/Desktop
ln -s $SDCARD root/sdcard
ln -s $SDCARD root/Desktop/sdcard

echo "Updating lib paths"
./updatelibpaths.sh > libpaths

ls lib/ld-linux-armel.so.3 && ln -s ld-linux-armhf.so.3 lib/ld-linux.so.3
ls lib/ld-linux-armhf.so.3 && ln -s ld-linux-armhf.so.3 lib/ld-linux.so.3

echo "Adding user $USER ID $USER_ID"
# This command fails on Galaxy Note 3
#./chroot.sh bin/bash usr/bin/fakeroot-sysv usr/sbin/useradd -U -m -G sudo,staff  '$1$nFL/I4tz$zHKmBfkaKmRRmWje1Mupm0' -u $USER_ID $USER 2>&1
echo "$USER:x:$USER_ID:" >> etc/group
echo "$USER:!::" >> etc/gshadow
echo "$USER:x:$USER_ID:$USER_ID::/home/$USER:/bin/sh" >> etc/passwd
echo "$USER:$1$nFL/I4tz$zHKmBfkaKmRRmWje1Mupm0:16019:0:99999:7:::" >> etc/shadow
mkdir home/$USER
./chroot.sh bin/cp -a -f etc/skel/.* home/$USER/ 2>&1
./chroot.sh bin/cp -a -f root/* root/.* home/$USER/ 2>&1

echo "Postinstall script finished"
