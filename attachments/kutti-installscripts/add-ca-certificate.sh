#!/bin/bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] CERTIFICATEFILENAME

Options:
  -r    Removes the certificate from the trust store, if it exists.
  -h    Shows this help message.

Notes:
EOF
    if [[ $EUID -ne 0 ]]; then
        echo "  * MUST be run with root privileges."
    fi
    echo
}

REMOVE_FLAG=0

# Option parsing
while getopts "hr" opt; do
    case "$opt" in
        h)
            usage
            exit 0
            ;;
        r)
            REMOVE_FLAG=1
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

# Fast-pass validation for positional argument
if [[ $# -lt 1 ]] || [[ -z "$1" ]]; then
    usage
    exit 1
fi

# Ensure root privilege ($EUID is a built-in Bash variable)
if [[ $EUID -ne 0 ]]; then
    echo "Error: $0 must be run as root. Use sudo." >&2
    exit 1
fi

CERT_PATH="$1"
CERT_NAME="$(basename "$CERT_PATH")"
TARGET_DIR="/usr/local/share/ca-certificates"

if [[ $REMOVE_FLAG -eq 0 ]]; then
    if [[ ! -f "$CERT_PATH" ]]; then
        echo "Error: Certificate file '$CERT_PATH' does not exist." >&2
        exit 1
    fi

    echo "Copying $CERT_PATH to $TARGET_DIR..."
    cp "$CERT_PATH" "$TARGET_DIR/$CERT_NAME"
else
    echo "Deleting $CERT_NAME from $TARGET_DIR..."
    rm -f "$TARGET_DIR/$CERT_NAME"
fi

echo "Updating CA certificates..."
update-ca-certificates

echo "Done."
