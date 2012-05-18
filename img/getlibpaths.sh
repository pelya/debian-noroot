#!/bin/sh
cd dist-office-backup
echo -n export LD_LIBRARY_PATH=
find . -name "*.so" -exec dirname {} \; | sort | uniq | sed 's@^./@`pwd`/@' | while read DD; do echo -n ":$DD"; done

