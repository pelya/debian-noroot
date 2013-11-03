Run Debian on top of Android with a single click.
=================================================

No root required! Should work on any high-end device!
Unleash full unrestricted desktop environment onto your mobile device!
Instant frustration guaranteed! (unless you're using mouse or stylus).

GIMP image editor, or office suite pre-installed (AbiWord and Gnumeric, there's no PowerPoint support).
You will need 180 Mb free on internal data storage (or 200 Mb for office suite), plus 320 Mb on SD card.

This app is NOT full Debian OS - it is a compatibility layer, which allows you to run Debian applications.
Your phone is NOT rooted during installation. 
Also, this is NOT official Debian.org release.

There are several limitations:

- It cannot mess up your Android device.
- No pseudo-terminal support, so Libreoffice, XTerm and many other applications do not work.
- Desktop environment is slightly broken.
- Package manager crashes often.
- No audio support. Maybe it will be added in the future, however it will lag a lot, and there's no way to fix the lag.
- No OpenGL support. It's possible to add it but it's a huge chunk of work, and I will not be doing that.
- No access to the device hardware. That means you cannot re-partition SD card, you cannot burn CD-Roms, you cannot run ping or sniff your network etc.
- No ability to move app to SD card, you will need unified storage as in Nexus 7 / Note 3.

How does that work.
===================

The Ubuntu shell is launched using the "fakechroot" method, then it connects to XSDL X server.
It uses LD_PRELOAD with libfakechroot.so and libfakedns.so (which is a re-implementation of the DNS client library,
required because DNS-related calls are incompatible between Android and glibc).

Development.
============

You'll need Android SDK and following packages:
For Ubuntu 12.04:
```
sudo apt-get install autotools debhelper build-essentials qemu-user-static gcc-arm-linux-gnueabi debootstrap
```
For Debian Jessie:
```
sudo apt-get install autoconf automake debhelper build-essential libtool qemu-user-static debootstrap emdebian-archive-keyring
echo deb http://www.emdebian.org/debian/ testing main | sudo tee /etc/apt/sources.list.d/emdebian.list
sudo apt-get update
sudo apt-get install g++-4.7-arm-linux-gnueabi
mkdir ~/bin
cd ~/bin
ln -s /usr/bin/arm-linux-gnueabi-gcc-4.7 arm-linux-gnueabi-gcc
ln -s /usr/bin/arm-linux-gnueabi-g++-4.7 arm-linux-gnueabi-g++
```

Run
```
git submodule update --init
./build.sh
```
That should compile the libfakechroot.so and libfakedns.so files.
The XSDL X server is in external repository - to compile it, run:
```
git clone git@github.com:pelya/commandergenius.git
git submodule update --init project/jni/application/xserver/xserver
rm project/jni/application/src
ln -s xserver project/jni/application/src
./changeAppSettings.sh -a
android update project -p project
./build.sh
```
then install resulting .apk file on your Android device, and run it.

The scripts for creating Ubuntu images are located in directory "img".

If you want to dig into things deeper, and launch your own Ubuntu image from the Android debug console (ADB),
do following steps (you don't need to root your device for that):

Open all relevant .sh files in the text editor, and try to understand what are they doing.

Launch command

```
cd img
sudo ./img-debug-squeeze.sh
```

it will prepare an image to be installed into directory /data/local/ubuntu on your device.
It will automatically launch the script img/prepare-img.sh, which will mangle the symlinks inside the Ubuntu image,
so that they will work inside fakechroot environment.

Plug your Android device into the PC via USB cable, and enable USB debugging inside Settings in Android device,
or launch Android 4 emulator with at least 1 Gb internal storage size.
Android 2.3 will not work for debug image because it needs armeabi-v7a CPU.

Launch command:
```
adb shell mkdir /data/local/tmp/img
adb push img/img-debug-squeeze.tar.gz /data/local/tmp/img
adb push dist/busybox /data/local/tmp/img
adb shell
cd /data/local/tmp/img
chmod 755 busybox
./busybox tar xvf dist-debug-squeeze.tar.gz
./postinstall.sh
```

That script will unpack the Ubuntu directory tree with binaries and symlinks into the current directory
(which should be /data/local/tmp/img), and will do some extra preparations. It might output some errors, ignore them.

Then you will be able to launch Debian commands by running script ./chroot.sh from the directory /data/local/tmp/img, for example
```
./chroot.sh bin/sh
```
will launch the familiar shell inside chroot, or bash shell (it does not work with Ubuntu 12.04)
```
./chroot.sh bin/bash
```
To launch graphical desktop, launch from inside chroot-ed shell
```
./startx.sh
```

The script chroot.sh contains a huge LD_LIBRARY_PATH variable, which lists all directories where a shared library can be found,
that is because the loader lib/ld-linux.so.3 is confused by a fakechroot environment, and should be told explicitly what directories to search.
You may get that list by running shell script img/getlibpaths.sh

As of now, LibreOffice does not work because Java cannot be launched (however there's native Android port of LibreOffice in the works now,
so there's not much point in making it work inside Ubuntu environment).

Also, Gnome, KDE and LXDE desktop environments do not work, only XFCE4 works, that's most probably because of missing pseudo-TTY support.
If you want to add pseudo-TTY support, you need to implement another LD_PRELOAD-ed library, libfakepty.so or something like that,
which will emulate following system calls in user space (you don't need to do any kernel stuff, PTYs will be shared only between processes inside chroot):
- openpty
- posix_openpt
- forkpty
- getttyent
- setttyent
- endttyent
- getttynam
- isatty
- login_tty
- ttyname
- ttyname_r
- ttyslot
- ptsname
- ptsname_r
- getpt
- grantpt
- unlockpt
- everything mentioned in "man termios" page
- subset of ioctl calls which are related to pseudo-terminals - see "man tty_ioctl" and "man console_ioctl"

Not all of these calls are used everywhere, I think it's enough to implement only the calls referenced by XTerm binary.
