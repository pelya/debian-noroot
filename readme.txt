Run Ubuntu on top of Android with a single click.
=================================================

No root required! You will need 500 Mb of internal storage (it cannot be installed to SD card).

This app is NOT full Ubuntu OS - it is a compatibility layer, which allows you to run some Ubuntu applications.
Also, this is not official ubuntu.com release.

There are several limitations:

- It cannot mess up your Android device. It is a plain regular Android app, so you can close or kill it when you desire.
- Video output is slow. This can be improved greatly by creating native Android X.org server (Xsdl is a good place to start).
- No audio support. Maybe it will be added in the future, however it will lag a lot, and there's no way to fix the lag.
- No hardware mouse support. Probably it will be added in the future.
- No OpenGL support. It's possible to add it but it's a huge chunk of work, and I will not be doing that.
- No access to the device hardware. That means you cannot re-partition SD card, you cannot burn CD-Roms, you cannot sniff your network etc.
- No camera support. It's possible to add, however not worth the effort - I don't know any Ubuntu apps that use camera (except for Skype, but it's already available as a native app).
- No multitouch support - this is a limitation of Ubuntu itself.
- No ability to move app to SD card. This can be improved by offloading non-executable files to SD card with a symlink, and packing executables with UPX.
- No pseudo-terminal support, so XTerm and many utilities do not work.

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
