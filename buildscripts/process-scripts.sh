#!/bin/bash -eu
SCRIPT_LOCATION="/opt/kutti/scripts"

echo "Converting windows line endings in scripts..."
sed --in-place "s/\r//g" "${SCRIPT_LOCATION}"/*.sh
echo "Ensuring tool scripts are executable..."
chmod +x "${SCRIPT_LOCATION}"/*.sh
echo "Creating links for tool scripts..."
ln -v -s -t /usr/local/bin/ "${SCRIPT_LOCATION}"/*.sh
echo "Done."
