#!/bin/bash
set -e

function usage () {
    echo "Usage: $0 [OPTIONS] CERTIFICATEFILENAME"
    echo
    echo "Options:"
    echo "-h    Shows this help. No further parameters required."
    echo "-r    Removes the certificate, if it exists."
    echo
    if [ "$(id -ur)" -ne 0 ]; then
        echo "Note: MUST be run with root privileges"
        echo
    fi
}

if [ "$1" == "" ] || [ "$1" = "-h" ] ; then
    usage

    exit 1
fi

if [ "$1" == "-r" ]; then
    REMOVE_FLAG=1

    shift
fi

if [ "$1" == "" ];  then
    usage

    exit 1
fi

if [ "$(id -ur)" -ne 0 ]; then
    echo "$0 can only be run as root. Use sudo."
    exit 1
fi

if [ "$REMOVE_FLAG" == "" ]; then
    echo "Copying $1 to /usr/local/share/ca-certificates..."
    cp "$1"  /usr/local/share/ca-certificates/
else
    echo "Deleting $1 from /usr/local/share/ca-certificates..."
    rm  "/usr/local/share/ca-certificates/$1"
fi

echo "Updating CA certificates..."
update-ca-certificates

echo "Done."