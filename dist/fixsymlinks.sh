#!./busybox

if ./busybox [ -n "$1" ]; then
	TARGET="`./busybox readlink $1`"
	if echo "$TARGET" | ./busybox grep '^/' > /dev/null; then
		echo "$1 -> $TARGET - absolute link, expanding"
		rm "$1"
		ln -s "`pwd`$TARGET" "$1"
	else
		echo "$1 -> $TARGET - relative link, ignoring"
	fi
else
	./busybox find -type l -exec ./busybox sh $0 {} \;
fi
