#!/bin/sh
[ "$USER" = "root" ] || { echo This script needs to be run with superuser privileges; exit 1;}

DIST=dist-minimal

[ -z "$1" ] || DIST="$1"

ARCH="$2"

PWD=`pwd`
cd $DIST
rm -f var/cache/apt/archives/*.deb
find var/log -type f -delete

# Processing binaries through UPX will make them unusable on Android

#echo "Packing binaries (10 Mb savings)"
#BEFORE_UPX="`du -h -s .`"
#find -name "*.so*" -o -type f -exec file {} \; | grep 'ELF 32' | sed 's@^\([^ ]*\): .*@\1@' | while read F; do echo $F > /dev/stderr ; upx --best $F > /dev/null 2>&1 ; done
#echo "Before UPX: $BEFORE_UPX after UPX: `du -h -s .`"

cp -a $PWD/../dist/* .
[ -z "$ARCH" ] || cp -a -f $PWD/../dist-$ARCH/* .

ARCHIVE=`echo $DIST | sed 's@/.*@@'`
tar czf ../$ARCHIVE.tar.gz *
