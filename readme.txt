
Ubuntu running on top of Android, without rooting your phone.
=============================================================

Ubuntu is packaged as a regular Android application, and it's running
as a regular Android application, with no root access required,
and without bypassing the Android security model.
You can close or kill it as any other app, and it cannot deadlock or mess up your phone.

This is achieved by using "fakechroot" command, and running custom, very simple X.org server backed by the SDL library,
which adds several accessibility features for small-screen devices, like magnifying glass (don't expect much from them).

This is of course NOT full Ubuntu OS, however it allows you to run substantial amount of applications provided by the Ubuntu package manager.

There are several limitations:

- No audio support. Maybe it will be added in the future, however it will lag a lot, and there's no way to fix the lag.
- No hardware mouse support. Probably it will be added in the future.
- No OpenGL support. It's possible to add it but it's a huge chunk of work, and I will not be doing that.
- No access to the device hardware. That means you cannot re-partition SD card, you cannot burn CD-Roms using an external USB burner etc.
- No camera support. It's possible to add, however not worth the effort - I don't know any Ubuntu apps that use camera (except for Skype, but it's already available as a native app).
- No multitouch support. I might add touch pressure support to the GIMP, via the graphic tablet emulation.
