#!/system/bin/sh

export HOME=/root
export SHELL=/bin/bash
export USER=root
#export LD_LIBRARY_PATH=/lib:/usr/local/lib:/usr/lib
export LD_LIBRARY_PATH=
export PATH=/usr/local/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/bin:/bin:/usr/local/games:/usr/games
lib/ld-linux-armhf.so.3 --library-path lib/arm-linux-gnueabihf ./proot -r `pwd` -w / -b /dev -b /proc -b /sys -b /system -b $EXTERNAL_STORAGE bin/bash -l
