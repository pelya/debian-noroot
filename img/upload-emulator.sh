#!/bin/sh

adb shell mkdir -p /sdcard/Android/obb/com.cuntubuntu
adb push dist-debian-buster-x86_64.tar.xz /sdcard/Android/obb/com.cuntubuntu/main.191224.com.cuntubuntu.obb
