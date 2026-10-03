#!/bin/sh -eu

if [ "$(id -ur)" -ne "0" ]; then
    echo "$0 can only be run as root. Use sudo."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Install VirtualBox Guest Additions
echo "==> Installing VirtualBox Guest Additions"
# 1. Install prerequisites and FastTrack archive keyring
apt-get update
apt-get install -y ca-certificates gpg fasttrack-archive-keyring

# 2. Add FastTrack and Backports sources for Debian 12 (Bookworm)
cat << EOF > /etc/apt/sources.list.d/bookworm-fasttrack.sources
Types: deb deb-src
URIs: http://fasttrack.debian.net/debian-fasttrack/
Suites: bookworm-fasttrack bookworm-backports-staging
Components: main contrib
Enabled: yes
EOF

# 3. Update apt and install pre-compiled guest utilities
apt-get update
apt-get install -y virtualbox-guest-utils

echo "Done."

# Update GRUB settings
echo "==> Updating GRUB settings"

## Set boot loader timeout to 0
echo "Seting boot loader timeout"
sed -i 's/GRUB_TIMEOUT=\(.*\)/GRUB_TIMEOUT=0/g' /etc/default/grub;
echo "Done."

## Disable Predictable Network Interface names and use eth0

## This script disables "predictable interface names" like enp0s3,
## and restores the use of interface names like eth0.
## This seems to be needed if we use the virtualbox-ovf source,
## otherwise networking does not start on any VM created by the
## exported .ova file. The following issue gave the clue:
##   https://github.com/hashicorp/packer/issues/866
## and the solution was picked up from:
##   https://github.com/chef/bento/blob/master/packer_templates/debian/scripts/networking.sh

echo "Disabling predictable network interface names..."
## This script assumes that the names of all interfaces in
## /etc/network/interfaces will be replaced with eth0. This works
## for us, because we use only one interface connected to a NAT
## network.
sed -i 's/en[[:alnum:]]*/eth0/g' /etc/network/interfaces;
## Add kernel parameter to disable predictable interface names
sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 \1"/g' /etc/default/grub;
echo "Done."

## Update grub
echo "Updating GRUB..."
update-grub;
echo "Done."

# Add/edit directories and files

echo "==> Adding/editing directories and files..."

## Patch networking
## Replace the /etc/network/interfaces file completely, because 
## there seems to be a problem with VirtualBox 7 on Linux
cat >/etc/network/interfaces <<EOINTERFACES
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet dhcp

EOINTERFACES

## Adding a 2 sec delay to the interface up, to make the dhclient happy
echo "pre-up sleep 2" >> /etc/network/interfaces

## Prepend public DNS servers in dhclient.conf
## This is required because VirtualBox 7.2 has issues with DNS
## - https://github.com/VirtualBox/virtualbox/issues/447
echo "==> Prepending DNS via dhclient (Most Reliable for DHCP) ==="
DHCLIENT_CONF="/etc/dhcp/dhclient.conf"

if [ -f "$DHCLIENT_CONF" ]; then
    # Remove existing custom prepend entries to avoid duplicates
    sed -i '/prepend domain-name-servers/d' "$DHCLIENT_CONF"
    
    # Inject the public DNS ahead of dynamically assigned ones
    echo 'prepend domain-name-servers 8.8.8.8, 1.1.1.1;' >> "$DHCLIENT_CONF"
    echo "Successfully prepended DNS in $DHCLIENT_CONF"
else
    echo "$DHCLIENT_CONF not found. Skipping dhclient configuration."
fi

## Set up directory for later copying of kutti interface scripts
mkdir -p /opt/kutti/scripts
chown kuttiadmin:kuttiadmin /opt/kutti/scripts

## Set up basic motd
echo "Welcome to kutti." > /etc/motd

# Add required system packages
echo "==> Adding required system packages"

echo "Installing bash completion, socat, vim and curl..."
apt-get install -y apt-transport-https bash-completion socat vim curl
echo "Done."

# Add user1
echo "==> Adding user1"
adduser --gecos "User 1" --disabled-password user1
chpasswd <<EOPASSWD
user1:Pass@word1
EOPASSWD
adduser user1 sudo
