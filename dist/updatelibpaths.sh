#!/system/bin/sh

./busybox echo -n `pwd`
./busybox find . -name "*.so*" -exec ./busybox dirname {} \; | ./busybox sort | ./busybox uniq | ./busybox sed "s@^./@`pwd`/@" | while read DD; do ./busybox echo -n ":$DD"; done
