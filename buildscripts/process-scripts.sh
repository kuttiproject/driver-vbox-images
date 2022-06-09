#!/bin/bash -eu
echo "Converting windows line endings in scripts..."
sed --in-place "s/\r//g" /home/kuttiadmin/kutti-installscripts/*.sh
echo "Ensuring tool scripts are executable..."
chmod +x /home/kuttiadmin/kutti-installscripts/*.sh
echo "Creating links for tool scripts..."
ln -v -s -t /usr/local/bin/ /home/kuttiadmin/kutti-installscripts/*.sh
echo "Done."

