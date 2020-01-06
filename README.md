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
- No audio support. Some time ago PulseAudio was somewhat supported, but now it's broken.
- No OpenGL support. It's possible to add it but it's a huge chunk of work, and I will not be doing that.
- No access to the device hardware. That means you cannot re-partition SD card, you cannot burn CD-Roms, you cannot run ping or sniff your network etc.
- No ability to move app to SD card, so you will need a lot of internal storage.
- Most servers such as SSH or Apache won't start, because they all need root features.
  You can use tightvncserver instead of SSH, and wbox instead of Apache as a simple file sharing web server,

How does that work.
===================

The Debian graphical shell is launched using PRoot, the ultimate Linux virtualization solution: http://proot.me/
Then it launches XSDL X server to render it to screen.

Development.
============

You'll need Android SDK and following packages:
```
sudo apt-get install autoconf automake debhelper build-essential libtool qemu-user-static debootstrap pxz schroot apt-cacher-ng
```

The scripts for creating Debian images are located in directory "img".
To prepare image, run these scripts:

```
git submodule update --init --recursive
cd img
sudo ./img-debian-buster-arm64-v8a.sh
sudo ./img-debian-buster-x86_64.sh
cd ..
./build.sh
sudo mount -o bind . img/dist-debian-buster-arm64-v8a/img/mnt
sudo chroot img/dist-debian-buster-arm64-v8a/img
apt-get update
apt-get install gcc
cd mnt
./build.sh
exit
cd img
prepare-img-overlay.sh
```
That should build libandroid-shmem-disableselinux.so used to speed up drawing speed,
and prevent Debian from messing up with Android security features.

Proot is precompiled, taken from here:
https://bintray.com/termux/termux-packages-24/proot
https://bintray.com/termux/termux-packages-24/libtalloc

The XSDL X server is in an external repository - to compile it, follow instructions here:
https://github.com/pelya/commandergenius/tree/sdl_android/project/jni/application/xserver-debian
then install resulting .apk file on your Android device, and run it.
