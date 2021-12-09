#!/bin/bash -eu

echo "Creating links for tool scripts..."
ln -v -s -t /usr/local/bin/ /home/kuttiadmin/kutti-installscripts/*.sh
echo "Done."

