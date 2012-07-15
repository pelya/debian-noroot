Run Ubuntu on top of Android with a single click.
=================================================

No root required! Should work on any high-end device!
Unleash full unrestricted desktop environment onto your mobile device!
Instant frustration guaranteed! (unless you're using mouse or stylus).

GIMP image editor, or office suite pre-installed (AbiWord and Gnumeric, there's no PowerPoint support).
You will need 180 Mb free on internal data storage (or 200 Mb for office suite), plus 320 Mb on SD card.

This app is NOT full Ubuntu OS - it is a compatibility layer, which allows you to run many Ubuntu applications.
Your phone is NOT rooted during installation. 
Also, this is NOT official Ubuntu.com release.

There are several limitations:

- It cannot mess up your Android device. It is a plain regular Android app, so you can close or kill it when you desire.
- Desktop environment is broken - this will get fixed if you'll use Ubuntu 12.04 instead of 10.04, however 12.04 works only on devices with 3.0.X or newer kernel.
- Package manager does not work, pre-installed packages is all you will get - this also will get fixed with Ubuntu 12.04
- Video output is slow. This can be improved by creating native Android X.org server (Xsdl is a good place to start).
- No audio support. Maybe it will be added in the future, however it will lag a lot, and there's no way to fix the lag.
- No hardware mouse support. Probably it will be added in the future.
- No OpenGL support. It's possible to add it but it's a huge chunk of work, and I will not be doing that.
- No access to the device hardware. That means you cannot re-partition SD card, you cannot burn CD-Roms, you cannot run ping or sniff your network etc.
- No camera support. It's possible to add, however not worth the effort, since Ubuntu can access photos on your SD card.
- No multitouch support - this is a limitation of Ubuntu itself.
- No ability to move app to SD card (this can be mitigated in future by more dirty hacks).
- No pseudo-terminal support, so XTerm and many utilities do not work.

This app was tested Samsung Galaxy Note, HTC Evo and Android 4 emulator. It does not run on Android 2.3 emulator.

How does that work.
===================

The Ubuntu shell is launched using the "fakechroot" method, it starts Xvnc server, and connects with androidVNC client.
It uses LD_PRELOAD with libfakechroot.so and libfakedns.so (which is a re-implementation of the DNS client library,
required because DNS-related calls are incompatible between Android and glibc).

Development.
============

You'll need Android SDK and following packages:
autotools debhelper build-essentials qemu-user-static gcc-arm-linux-gnueabi

Run
git submodule update --init
then run
./build.sh
That should compile the .apk file. You'll also need to change URL to the Ubuntu image inside androidVNC/androidVNC/src/com/cuntubuntu/DataDownloader.java, in array named downloadFiles.
If you want to recompile libfakechroot.so and libfakedns.so you wil need to do that from Debian Lenny,
because default Ubuntu crosscompiler can only compile for CPU with hardware floating point support.
Use script prepare-build-env.sh to set up Debian Lenny environment.

The scripts for creating Ubuntu images are located in directory "img".

If you want to dig into things deeper, and launch your own Ubuntu image from the Android debug console (ADB),
do following steps (you don't need to root your device for that):

Open all relevant .sh files in the text editor, and try to understand what are they doing.

Launch command
cd img ; sudo ./img-debug.sh
it will prepare an image to be installed into directory /data/local/ubuntu on your device.
It will automatically launch the script img/prepare-img.sh, which will mangle the symlinks inside the Ubuntu image,
so that they will work inside fakechroot environment, also it will move all regular non-executable files and dirs which contain
only such files out of the image to be installed onto SD card, this reduces the internal device memory usage from 500 to around 200 Mb.
You may use pre-built image at http://sourceforge.net/projects/libsdl-android/files/ubuntu/dist-debug.zip

Plug your Android device into the PC via USB cable, and enable USB debugging inside Settings in Android device.
You may also use Android 4 emulator, Android 2.3 will not work for debug image because it needs armeabi-v7a CPU.
Debian Lenny may be launched on armeabi CPU and Android 2.3 emulator, however creating the system image is complicated.

Determine where your SD card is located (it can be accessed by symlink /sdcard/ on both of my devices and on emulator):
adb shell ls -l /sdcard/
That should print you your SD card contents, and all following instructions assume the path /sdcard/ to be working.

Copy the resulting system image to SD card, and unzip it to directory named "ubuntu", using any file manager for Android.
Do not use command "adb push img/dist-debug/ /sdcard/ubuntu/", it will not copy empty directories.

Launch command:
adb shell

From ADB shell, execute following commands:
cd /data/local/ubuntu
cat /sdcard/ubuntu/postinstall.sh > postinstall.sh
chmod 755 postinstall.sh
export SDCARD_UBUNTU=/sdcard/ubuntu
./postinstall.sh

That script will unpack the Ubuntu directory tree with binaries and symlinks into the current directory
(which should be /data/local/ubuntu), and will do some extra preparations. It might output some errors, ignore them.

Then you will be able to launch Ubuntu commands by running script ./chroot.sh from the directory /data/local/ubuntu, for example
./chroot.sh bin/sh
will launch the familiar shell inside chroot, or bash shell (it does not work with Ubuntu 12.04)
./chroot.sh bin/bash

The script chroot.sh contains a huge LD_LIBRARY_PATH variable, which lists all directories where a shared library can be found,
that is because the loader lib/ld-linux.so.3 is confused by a fakechroot environment, and should be told explicitly what directories to search.
You may get that list by running shell script img/getlibpaths.sh

To start X VNC server launch following commands inside the shell:
export DISPLAY_RESOLUTION=1280x800 (place your actual screen resolution here)
/fakeroot.sh
/startx.sh

Install android-vnc-viewer app from the Google Play onto your device, and enter following connection info:
Address: 127.0.0.1
Port: 7011
Password: ubuntu

Then click "Connect", then you should be able to interact with your Ubuntu installation through the graphical interface.
You can then launch random commands, like "xeyes" or "xev" from the Bash shell, and see them appear on the device screen.
The error messages dumped to the Bash shell are invaluable source of information about what you need to fix to make each particular application work.
As of now, LibreOffice does not work because Java cannot be launched (however there's native Android port of LibreOffice in the works now,
so there's not much point in making it work inside Ubuntu environment).
