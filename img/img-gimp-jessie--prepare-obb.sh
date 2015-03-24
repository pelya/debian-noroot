#!/bin/sh

[ -e dist-gimp-jessie-armeabi-v7a -a -e dist-gimp-jessie-x86 ] || {
	echo "Please run scripts img-gimp-jessie-x86.sh and img-gimp-jessie-armhf.sh first"
	exit 1
}

DIR1=dist-gimp-jessie-armeabi-v7a/img
DIR2=dist-gimp-jessie-x86/img
OUTDIR=dist-gimp-jessie

rm -rf $OUTDIR

mkdir -p $OUTDIR/img
cp -a $DIR1 $OUTDIR/img-armeabi-v7a
cp -a $DIR2 $OUTDIR/img-x86
cd $OUTDIR
../merge-dirs.sh img-armeabi-v7a img-x86 img
tar c * | xz -8 > ../$OUTDIR.tar.xz
