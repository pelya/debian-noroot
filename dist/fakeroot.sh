#!/bin/sh

# This script first starts faked (the daemon), and then it will run
# the requested program with fake root privileges.

# strip /bin/fakeroot to find install prefix
FAKEROOT_PREFIX=/usr
FAKEROOT_BINDIR=/usr/bin

LIB=libfakeroot-sysv.so
FAKED=${FAKEROOT_BINDIR}/faked-sysv

FAKED_MODE="unknown-is-root"
export FAKED_MODE

if test "$?" -ne 0; then
  echo Specify command
  exit
fi

FAKEDOPTS=""
PIPEIN=""
WAITINTRAP=0

if test -n "$FAKEROOTKEY"; then
    echo "FAKEROOTKEY set to $FAKEROOTKEY" "nested operation not yet supported"
    exit
fi

unset FAKEROOTKEY
KEY_PID=`eval $FAKED $FAKEDOPTS $PIPEIN`
FAKEROOTKEY=`echo $KEY_PID|cut -d: -f1`
PID=`echo $KEY_PID|cut -d: -f2`

if [ "$WAITINTRAP" -eq 0 ]; then
  trap "kill -s TERM $PID" EXIT INT
else
  trap 'FAKEROOTKEY=$FAKEROOTKEY LD_LIBRARY_PATH="$PATHS" LD_PRELOAD="$LIB" /bin/ls -l / >/dev/null 2>&1; while kill -s TERM $PID 2>/dev/null; do sleep 0.1; done' EXIT INT
fi

if test -z "$FAKEROOTKEY" || test -z "$PID"; then
  fatal "error while starting the \`faked' daemon."
fi

if test -n "$LD_PRELOAD"; then
  LIB="$LD_PRELOAD $LIB"
fi

env FAKEROOTKEY=$FAKEROOTKEY LD_PRELOAD="$LIB" "$@"
RESULT=$?
exit $RESULT
