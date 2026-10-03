#!/bin/sh -eu

if [ "$(id -ur)" -ne "0" ]; then
    echo "$0 can only be run as root. Use sudo."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Clean Up
echo "==> Cleaning up"

echo "Removing unneeded software..."
## We do not need the following packages:
##   vim-tiny 
##   installation-report
apt-get purge -y vim-tiny installation-report perl
echo "Done."

## The "laptop" tasksel task seems to be autoselected for whatever reason.
## Remove it while ignoring errors
echo "trying to remove *laptop* tasksel task..."
tasksel remove laptop && echo "Done." || echo "Laptop task could not be removed."

# Remove specific kernel packages except the running kernel version
echo "Purging unused kernel packages..."
RUNNING_KERNEL=$(uname -r)

# Filter for packages matching linux-image-<digit> and linux-headers-<digit>,
# excluding the running kernel version
dpkg-query -f '${Package}\n' -W 'linux-image-[0-9]*' | grep -v "${RUNNING_KERNEL}" | xargs -r apt-get purge -y
dpkg-query -f '${Package}\n' -W 'linux-headers-[0-9]*' | grep -v "${RUNNING_KERNEL}" | xargs -r apt-get purge -y

update-grub
echo "Done."


## Apt autoremove for all residual stuff
echo "Autoremoving unneeded software..."
apt-get autoremove -y
echo "Done."

