#!/bin/sh

cd fakechroot
[ -e fakechroot_2.16.orig.tar.gz ] || git archive --format=tar HEAD | gzip > ../fakechroot_2.16.orig.tar.gz
dpkg-buildpackage -aarmel -us -uc
