Run Debian on top of Android with a single click.
=================================================

No root required! Should work on any high-end device!
Unleash full unrestricted desktop environment onto your mobile device!
Instant frustration guaranteed! (unless you're using mouse or stylus).

This app is NOT full Debian OS - it is a compatibility layer, which allows you to run Debian applications.
Your phone is NOT rooted during installation.
Also, this is NOT official Debian.org release.

There are several limitations:

- It cannot mess up your Android device, because it's a regular well-behaved Android app, which does not need root access.
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
```
sudo apt-get install autoconf automake debhelper build-essential libtool qemu-user-static debootstrap emdebian-archive-keyring
echo deb http://www.emdebian.org/debian/ unstable main | sudo tee /etc/apt/sources.list.d/emdebian.list
sudo apt-get update
sudo apt-get install g++-4.7-arm-linux-gnueabihf
mkdir ~/bin
cd ~/bin
ln -s /usr/bin/arm-linux-gnueabihf-gcc-4.7 arm-linux-gnueabihf-gcc
ln -s /usr/bin/arm-linux-gnueabihf-g++-4.7 arm-linux-gnueabihf-g++
```

Run
```
git submodule update --init --recursive
./build.sh
```
That should compile the libfakechroot.so and libfakedns.so files.
The XSDL X server is in external repository - to compile it, run:
```
sudo apt-get install bison libpixman-1-dev \
libxfont-dev libxkbfile-dev libpciaccess-dev \
xutils-dev xcb-proto python-xcbgen xsltproc \
x11proto-bigreqs-dev x11proto-composite-dev \
x11proto-core-dev x11proto-damage-dev \
x11proto-dmx-dev x11proto-dri2-dev x11proto-fixes-dev \
x11proto-fonts-dev x11proto-gl-dev \
x11proto-input-dev x11proto-kb-dev \
x11proto-print-dev x11proto-randr-dev \
x11proto-record-dev x11proto-render-dev \
x11proto-resource-dev x11proto-scrnsaver-dev \
x11proto-video-dev x11proto-xcmisc-dev \
x11proto-xext-dev x11proto-xf86bigfont-dev \
x11proto-xf86dga-dev x11proto-xf86dri-dev \
x11proto-xf86vidmode-dev x11proto-xinerama-dev \
libxmuu-dev libxt-dev libsm-dev libice-dev \
libxrender-dev libxrandr-dev curl autoconf automake libtool

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

This app uses PRoot for chrooting into Debian rootfs,
the fakechroot method is not used anymore.
PRoot can be downloaded from:
```
http://proot.me/
```
