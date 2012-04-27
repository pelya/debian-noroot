#!/bin/sh
cd xxx
echo -n export LD_LIBRARY_PATH=
find . -name "*.so" -exec dirname {} \; | sort | uniq | sed 's@^./@`pwd`/@' | while read DD; do echo ":$DD"; done

