adb shell mkdir /sdcard/u
adb push chroot-sd.sh /data/local/u
adb push ../libfakechroot.so /data/local/u
adb push ubuntu.tar.gz /sdcard/ubuntu.tar.gz
adb shell "cd /sdcard/u && tar xzvf /sdcard/ubuntu.tar.gz"
echo "Environment is set, now do 'adb shell' -> 'cd /data/local/u' -> './chroot-sd.sh' and enjoy 'Operation not permitted' error instead of your Ubuntu shell"
