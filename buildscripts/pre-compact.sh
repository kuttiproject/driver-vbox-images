#!/bin/sh -ux

if [ "$(id -ur)" -ne "0" ]; then
    echo "$0 can only be run as root. Use sudo."
    exit 1
fi

dd if=/dev/zero of=zerofillfile bs=1G
sync
sleep 1
rm zerofillfile
sync
sleep 1
exit 0
