#!/bin/sh

adb shell mkdir -p /sdcard/Android/obb/com.cuntubuntu
adb push dist-debian-buster-arm64-v8a.tar.xz /sdcard/Android/obb/com.cuntubuntu/main.191224.com.cuntubuntu.obb
