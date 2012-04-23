adb shell mkdir /data/local/u
adb push chroot.sh /data/local/u
adb push ../libfakechroot.so /data/local/u
adb push ubuntu.tar.gz /data/local
adb shell "cd /data/local/u && tar xzvf /data/local/ubuntu.tar.gz"
echo "Environment is set, now do 'adb shell' -> 'cd /data/local/u' -> './chroot.sh' and enjoy your stripped Ubuntu shell"
