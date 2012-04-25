adb shell mkdir /data/local/tmp/u
adb push busybox /data/local/tmp/u
adb push fixsymlinks.sh /data/local/tmp/u
adb push armel-precise-ubuntu-minimal,lxde,fakeroot,fakechroot,tightvncserver,synaptic,wget-20120425.tgz /sdcard/ubuntu.tar.gz
adb shell "cd /data/local/tmp/u && ./busybox tar xzvf /sdcard/ubuntu.tar.gz"
adb shell "cd /data/local/tmp/u && ./busybox sh ./fixsymlinks.sh"
adb push libfakechroot.so /data/local/tmp/u
adb push chroot.sh /data/local/tmp/u
# Random post-install cmds
adb shell mkdir /data/local/tmp/u/sdcard
adb shell mkdir /data/local/tmp/u/root
adb shell mkdir /data/local/tmp/u/root/.vnc
adb push passwd /data/local/tmp/u/root/.vnc/passwd
adb push xstartup /data/local/tmp/u/root/.vnc/xstartup
adb shell ln -s /data/local/tmp/u/usr/bin/dbus-launch /data/local/tmp/u/bin/dbus-launch
adb shell "echo nameserver 8.8.8.8 > /data/local/tmp/u/etc/resolv.conf"
adb shell "echo nameserver 8.8.4.4 >> /data/local/tmp/u/etc/resolv.conf"
echo "Environment is set, now do 'adb shell' -> 'cd /data/local/tmp/u' -> './chroot.sh' and enjoy your stripped Ubuntu shell"
