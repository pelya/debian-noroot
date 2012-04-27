Run Ubuntu on top of Android with a single click.
=================================================

No root required!
Unleash full unrestricted desktop environment onto your mobile device!
Instant frustration guaranteed! (unless you're using mouse or stylus)

You will need 500 Mb of internal storage (it cannot be installed to SD card).

This app is NOT full Ubuntu OS - it is a compatibility layer, which allows you to run some Ubuntu applications.
Also, this is NOT official Ubuntu.com release.

There are several limitations:

- It cannot mess up your Android device. It is a plain regular Android app, so you can close or kill it when you desire.
- Video output is slow. This can be improved by creating native Android X.org server (Xsdl is a good place to start).
- No audio support. Maybe it will be added in the future, however it will lag a lot, and there's no way to fix the lag.
- No hardware mouse support. Probably it will be added in the future.
- No OpenGL support. It's possible to add it but it's a huge chunk of work, and I will not be doing that.
- No access to the device hardware. That means you cannot re-partition SD card, you cannot burn CD-Roms, you cannot run ping or sniff your network etc.
- No camera support. It's possible to add, however not worth the effort - I don't know any Ubuntu apps that use camera (except for Skype, but it's already available as a native app).
- No multitouch support - this is a limitation of Ubuntu itself.
- No ability to move app to SD card. This can be improved by offloading non-executable files to SD card with a symlink, and packing executables with UPX.
- No pseudo-terminal support, so XTerm and many utilities do not work.
- Desktop main menu is messed up, you'll need to create desktop shortcuts to applications you're using.

How does that work.
===================

The Ubuntu shell is launched via the "fakechroot" command, it starts Xvnc server, and connects with androidVNC client.
See the script dist/chroot.sh for details.

Compilation.
============

You'll need Android NDK r7c and toolchain in your $PATH, Android SDK, autotools, debhelper, build-essentials, Debian ARM toolchain and other various commandline stuff.
Run
git submodule update --init
then run
./build.sh
That should be it. You'll also need to change URL to the Ubuntu image inside androidVNC/androidVNC/src/com/cuntubuntu/DataDownloader.java, in array named downloadFiles.
The script to create Ubuntu image is located in img/img.sh
