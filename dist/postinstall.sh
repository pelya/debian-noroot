#!/system/bin/sh

case x$SDCARD in x ) export SDCARD=$EXTERNAL_STORAGE;; esac
echo "SDCARD path: $SDCARD"
echo "Changing curdir to: $SECURE_STORAGE_DIR"
case x$SECURE_STORAGE_DIR in x ) echo ... > /dev/null;; * ) cd $SECURE_STORAGE_DIR;; esac

umask 002

SDCARD=`./busybox realpath $SDCARD`

ln -s $SDCARD sdcard
mkdir -p .$SDCARD

echo "Creating necessary directories"
# Random post-install cmds
mkdir var/run/dbus
mkdir var/run/xauth
mkdir run/dbus
mkdir run/xauth
ln -s /usr/bin/dbus-launch bin/dbus-launch
mkdir var/lib/dbus
mkdir root
mkdir root/Desktop
ln -s $SDCARD root/sdcard
ln -s $SDCARD root/Desktop/sdcard

# Export GIMP config to SD card
case x$UNSECURE_STORAGE_DIR in x ) echo ... > /dev/null;; * ) ./busybox cp -r root/.gimp-2.8/ $UNSECURE_STORAGE_DIR/gimp ; ./busybox rm -rf root/.gimp-2.8 ; ln -s $UNSECURE_STORAGE_DIR/gimp root/.gimp-2.8 ; ln -s $UNSECURE_STORAGE_DIR/gimp/fonts root/.fonts ;; esac

echo "Adding user $USER ID $USER_ID"
# This command fails on Galaxy Note 3
#./chroot.sh bin/bash usr/bin/fakeroot-sysv usr/sbin/useradd -U -m -G sudo,staff  '$1$nFL/I4tz$zHKmBfkaKmRRmWje1Mupm0' -u $USER_ID $USER 2>&1
echo "$USER:x:$USER_ID:" >> etc/group
echo "$USER:!::" >> etc/gshadow
echo "$USER:x:$USER_ID:$USER_ID::/home/$USER:/bin/sh" >> etc/passwd
echo "$USER:$1$nFL/I4tz$zHKmBfkaKmRRmWje1Mupm0:16019:0:99999:7:::" >> etc/shadow
mkdir home/$USER
./busybox cp -a -f etc/skel/.* home/$USER/ 2>&1
./busybox cp -a -f root/* root/.* home/$USER/ 2>&1

./proot.sh ./postinstall-locales.sh

echo "Postinstall script finished"
