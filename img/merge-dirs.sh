#!/bin/sh

if [ "$4" = "--check" ]; then
	if [ -e "$2" ] && cmp "$1" "$2" > /dev/null 2>&1; then
		mkdir -p `dirname "$3"`
		mv "$1" "$3"
		rm "$2"
	fi
	exit
fi

if [ -z "$1" ]; then
	echo "Usage: $0 dir1 dir2 outdir"
	echo "Moves identical files in both dir1 and dir2 to outdir"
	exit
fi

IN1="$1"
IN2="$2"
OUT="$3"
THIS="`realpath $0`"

rm -rf "$OUT"
mkdir -p "$OUT"

cd "$IN1"

find . -type f -exec $THIS "{}" "../$IN2/{}" "../$OUT/{}" --check \;
