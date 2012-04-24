
Ubuntu running on top of Android, without rooting your phone.
=============================================================

This is NOT full Ubuntu OS, however it allows you to run substantial amount of applications provided by the Ubuntu package manager.

There are several limitations:

- It cannot mess up your Android device. It is a plain regular Android app, so you can close or kill it when you desire.
- Video output is slow. This can be improved greatly by creating native Android X.org server (Xsdl is a good place to start).
- No audio support. Maybe it will be added in the future, however it will lag a lot, and there's no way to fix the lag.
- No hardware mouse support. Probably it will be added in the future.
- No OpenGL support. It's possible to add it but it's a huge chunk of work, and I will not be doing that.
- No access to the device hardware. That means you cannot re-partition SD card, you cannot burn CD-Roms, you cannot sniff your network etc.
- No camera support. It's possible to add, however not worth the effort - I don't know any Ubuntu apps that use camera (except for Skype, but it's already available as a native app).
- No multitouch support - this is a limitation of Ubuntu itself.
- Whole image resides in your device internal memory, which is very limited, because Android does not allow executable code to be run from SD card.
This may be partially fixed by moving /usr/share to SD card (although it contains symlinks, and SD card does not support those).

How does that work.
===================

The Ubuntu shell is launched via the "fakechroot" command, it starts Xvnc server, and Android side connects via the VNC client.

Compilation.
============

You'll need Android NDK r7c and toolchain in your $PATH, Android SDK, autotools, debhelper, build-essentials, Debian ARM toolchain and other various commandline stuff.
Run
git submodule update --init
then run
./build.sh
That should be it.
