#!/bin/sh -eu

if [ "$(id -ur)" -ne "0" ]; then
    echo "$0 can only be run as root. Use sudo."
    exit 1
fi

cat > /etc/kutti-release <<EOF_RELEASESTAMP
Kutti VirtualBox Image Version: ${VM_VERSION}
Debian Linux Version: $(cat /etc/debian_version)
Containerd Version: $(containerd -v | cut -f3 -d " ")
Kubernetes Version: $(kubectl version --client -o yaml | grep "gitVersion" | cut -f2 -d ":")
EOF_RELEASESTAMP