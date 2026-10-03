#!/bin/bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  -r    Removes captured CA certificates from the trust store, if any.
  -h    Shows this help message.

Notes:
EOF
    if [[ $EUID -ne 0 ]]; then
        echo "  * MUST be run with root privileges."
    fi
    echo
}

REMOVE_FLAG=0

# Parse options
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

# Reject unexpected positional arguments
if [[ $# -gt 0 ]]; then
    echo "Error: Unexpected argument '$1'. Only -r or -h options are allowed." >&2
    usage
    exit 1
fi

# Ensure root privilege ($EUID is a built-in Bash variable)
if [[ $EUID -ne 0 ]]; then
    echo "Error: $0 must be run as root. Use sudo." >&2
    exit 1
fi

TARGET_DIR="/usr/local/share/ca-certificates"
CERT_NAME="captured-ca.crt"
TARGET_PATH="${TARGET_DIR}/${CERT_NAME}"

# Handle removal flag
if [[ $REMOVE_FLAG -eq 1 ]]; then
    echo "Removing captured CA certificates..."
    if [[ -f "$TARGET_PATH" ]]; then
        rm -f "$TARGET_PATH"
    fi
    
    echo "Updating CA certificates trust store..."
    update-ca-certificates --fresh
    
    echo "Done."
    exit 0
fi

echo "Capturing CA certificates..."

# Create secure temporary file and register automatic cleanup
TMP_CERT="$(mktemp /tmp/ca.XXXXXX.crt)"
trap 'rm -f "$TMP_CERT"' EXIT

# Fetch certificate chain from updated Kubernetes registry endpoint
if ! openssl s_client -showcerts -connect registry.k8s.io:443 < /dev/null 2>/dev/null \
    | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "$TMP_CERT"; then
    echo "Error: Failed to fetch certificates from registry.k8s.io." >&2
    exit 1
fi

# Ensure output file is non-empty before copying
if [[ ! -s "$TMP_CERT" ]]; then
    echo "Error: No valid certificates captured." >&2
    exit 1
fi

echo "Installing captured certificate to $TARGET_DIR..."
cp -f "$TMP_CERT" "$TARGET_PATH"
chmod 644 "$TARGET_PATH"

echo "Updating CA certificates trust store..."
update-ca-certificates

echo "Done."
