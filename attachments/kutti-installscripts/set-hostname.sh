#!/bin/bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] NEWHOSTNAME

Options:
  -h    Shows this help message.

Notes:
EOF
    if [[ $EUID -ne 0 ]]; then
        echo "  * MUST be run with root privileges."
    fi
    echo
}

# Handle help flag fast-pass
if [[ $# -eq 0 ]] || [[ "${1:-}" == "-h" ]]; then
    usage
    exit 1
fi

# Ensure root privilege ($EUID is a built-in Bash variable)
if [[ $EUID -ne 0 ]]; then
    echo "Error: $0 must be run as root. Use sudo." >&2
    exit 1
fi

NEW_HOSTNAME="$1"
OLD_HOSTNAME="$(hostname)"

echo "Setting hostname to '${NEW_HOSTNAME}'..."

if hostnamectl set-hostname "$NEW_HOSTNAME"; then
    # Safely update /etc/hosts using word-boundary matching to prevent unintended substring replacement
    if grep -qE "\b${OLD_HOSTNAME}\b" /etc/hosts; then
        sed -i -E "s/\b${OLD_HOSTNAME}\b/${NEW_HOSTNAME}/g" /etc/hosts
    else
        # If old hostname wasn't explicitly mapped, ensure 127.0.1.1 mapping exists for Debian
        if grep -q "127.0.1.1" /etc/hosts; then
            sed -i -E "s/^(127\.0\.1\.1\s+).*/\1${NEW_HOSTNAME}/" /etc/hosts
        else
            echo "127.0.1.1 ${NEW_HOSTNAME}" >> /etc/hosts
        fi
    fi

    # Regenerate Machine ID (fixes Weave Net duplicate peer issue & Debian machine-id)
    echo "Changing machine id..."
    rm -f /etc/machine-id /var/lib/dbus/machine-id
    
    # Generate new machine-id using native systemd tool
    systemd-machine-id-setup
    
    # Restore standard Debian symlink for legacy D-Bus applications
    mkdir -p /var/lib/dbus
    ln -sf /etc/machine-id /var/lib/dbus/machine-id

    # Regenerate SSH Host Keys to clear cloned template identity
    if [[ -d /etc/ssh ]]; then
        echo "Regenerating SSH host keys..."
        rm -f /etc/ssh/ssh_host_*
        DEBIAN_FRONTEND=noninteractive dpkg-reconfigure openssh-server
    fi

    echo "Done. Hostname, machine ID, and SSH host keys updated. Please reboot for changes to reflect."
    exit 0
else
    echo "Error: Failed to set hostname using hostnamectl." >&2
    exit 1
fi
