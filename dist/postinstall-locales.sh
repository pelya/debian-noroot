#!/bin/sh

if dpkg -s locales >/dev/null 2>&1 then
	echo "Updating locales"
else
	echo "No locales package installed, nothing to do"
	exit
fi

echo "$LANG UTF-8" >> /etc/locale.gen
/usr/bin/fakeroot /usr/sbin/dpkg-reconfigure --frontend=noninteractive locales
