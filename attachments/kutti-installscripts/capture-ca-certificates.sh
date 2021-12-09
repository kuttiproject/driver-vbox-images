#!/bin/bash
set -e

function usage () {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "-h    Shows this help"
    echo "-r    Removes captured CA certificates, if any."
    echo
    if [ "$(id -ur)" -ne 0 ]; then
        echo "Note: MUST be run with root privileges"
        echo
    fi
}

if [ "$1" = "-h" ] ; then
    usage

    exit 1
fi

if [ "$(id -ur)" -ne 0 ]; then
    echo "$0 can only be run as root. Use sudo."
    exit 1
fi

if [ "$1" = "-r" ]; then
    echo "Removing captured CA certficates..."
    if [ -f /etc/ssl/certs/ca.crt ]; then
        rm -f /etc/ssl/certs/ca.crt
    fi
    echo "Done."

    exit 0
fi

if [ ! "$1" = "" ]; then
    echo "Error: Only the -r or -h options are allowed."
    usage

    exit 1
fi

echo "Capturing CA certificates..."
PROCID=$$
openssl s_client -showcerts -connect k8s.gcr.io:443 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/ca.${PROCID}.crt
cp -f /tmp/ca.${PROCID}.crt /etc/ssl/certs/ca.crt
rm -f /tmp/ca.${PROCID}.crt
echo "Done."

exit 0
