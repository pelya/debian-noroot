#!/bin/sh
[ "$USER" = "root" ] || { echo This script needs to be run with superuser privileges; exit 1;}

DIST=dist-minimal
ROOTPATH=/data/data/com.cuntubuntu

[ -z "$1" ] || DIST="$1"
[ -z "$2" ] || ROOTPATH="$2"

ARCH="$3"

echo DIST $DIST ROOTPATH $ROOTPATH

rm -rf $DIST-sd $DIST.zip
cd $DIST
rm -f var/cache/apt/archives/*.deb
find var/log -type f -delete

if [ -n "$OFFLOAD_SDCARD" ]; then
echo "Offloading directories to SD card"

mkdir $DIST-sd

find -type d | sed 's@^[.]/@@' | while read F; do
	[ -d "$F" ] || continue # Previous iteration might have messed dir structure
	[ -z "`find $F -type f -executable`" ] || continue
	[ -z "`find $F -type l`" ] || continue
	[ -z "`find $F -type p`" ] || continue
	[ -z "`find $F -type s`" ] || continue
	[ -z "`find $F -type b`" ] || continue
	[ -z "`find $F -type c`" ] || continue
	[ -z "`find $F -type f -exec file {} \; | grep 'ELF 32'`" ] || continue
	[ -z "`find $F -type f | grep '[:\"*:<>?\\|]'`" ] || continue
	[ -z "`find $F -type f -name lock`" ] || continue
	# Directories var, run and tmp may not be moved, because they will contain files
	# which will be flock()-ed or lockf()-ed, and that operation cannot be performed on files on SD card, which has FAT32 filesystem.
	[ -z "`echo $F | grep '^var'`" ] || continue
	[ -z "`echo $F | grep '^tmp'`" ] || continue
	[ -z "`echo $F | grep '^run'`" ] || continue
	[ -z "`echo $F | grep '^root'`" ] || continue

	echo "Moving dir $F"
	ESCAPED=`echo "$F" | tr ':"*:<>?\\|' '----------'`
	mkdir -p "`dirname ../$DIST-sd/$ESCAPED`"
	mv "$F" "../$DIST-sd/$ESCAPED"
	ln -s "$ROOTPATH/sd/$ESCAPED" "$F"
done

echo "Offloading files to SD card"

find -type f -executable -o -type f -size "+4k" -exec file {} \; | grep -v 'ELF 32' | sed 's@^\([^ ]*\): .*@\1@' | sed 's@^[.]/@@' | while read F; do
	[ -z "`echo $F | grep '^var'`" ] || continue
	[ -z "`echo $F | grep '^tmp'`" ] || continue
	[ -z "`echo $F | grep '^run'`" ] || continue
	[ -z "`echo $F | grep '^root'`" ] || continue
	[ -z "`find $F -name lock`" ] || continue

	echo "$F"
	ESCAPED=`echo "$F" | tr ':"*:<>?\\|' '----------'`
	mkdir -p "`dirname ../$DIST-sd/$ESCAPED`"
	mv "$F" "../$DIST-sd/$ESCAPED"
	ln -s "$ROOTPATH/sd/$ESCAPED" "$F"
done

# var/cache/apt/*.bin var/cache/debconf/templates*  \
#		var/lib/apt/lists/*_Packages var/lib/apt/lists/*_Sources var/lib/apt/lists/*_Translation-* \
#		var/lib/aspell/* var/lib/gconf/defaults/* var/lib/usbutils/* var/lib/scrollkeeper/*/*
touch var/cache/apt/pkgcache.bin var/cache/apt/srcpkgcache.bin
for F in var/cache/apt/*.bin var/lib/apt/lists/*_Packages var/lib/apt/lists/*_Sources var/lib/apt/lists/*_Translation-* ; do
	[ -n "`find $F -type f`" ] || continue

	echo "$F"
	ESCAPED=`echo "$F" | tr ':"*:<>?\\|' '----------'`
	mkdir -p "`dirname ../$DIST-sd/$ESCAPED`"
	mv "$F" "../$DIST-sd/$ESCAPED"
	ln -s "$ROOTPATH/sd/$ESCAPED" "$F"
done
else
echo "Offloading files to SD card not done, use 'env OFFLOAD_SDCARD=1 $0'"
fi

# Processing binaries through UPX will make them unusable on Android

#echo "Packing binaries (10 Mb savings)"
#BEFORE_UPX="`du -h -s .`"
#find -name "*.so*" -o -type f -exec file {} \; | grep 'ELF 32' | sed 's@^\([^ ]*\): .*@\1@' | while read F; do echo $F > /dev/stderr ; upx --best $F > /dev/null 2>&1 ; done
#echo "Before UPX: $BEFORE_UPX after UPX: `du -h -s .`"

cp -a ../../dist/* .
[ -z "$ARCH" ] || cp -a -f ../../dist-$ARCH/* .

if [ -n "$OFFLOAD_SDCARD" ]; then
tar c * | gzip > ../$DIST-sd/binaries.tar.gz
cd ../$DIST-sd
zip -r ../$DIST.zip .
chmod a+rw ../$DIST.zip ../$DIST .
else
tar czf ..//$DIST.tar.gz *
fi
cd ..
