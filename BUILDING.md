# VM Images for kutti VirtualBox driver

The following instructions are for manual building of images. For automated building, see PACKER.md.

## Base Setup

1. Download **debian-12.10.0-amd64-netinst.iso** (Debian "bookworm" _"stable"_ release, _"netinst"_ image) via [https://www.debian.org/releases/](https://www.debian.org/releases/).
2. Create a virtual machine with at least 2 cores, 2GB RAM, VMSVGA video adapter, 16MB video memory and 100GB hard disk. Mount the iso from step 1 on the CDROM device. Boot. From the installer, choose "Install".
3. In the "Set up users and passwords" step, provide "Pass@word1" as the password for the root user. Next, create a user with the Full Name set as "Kutti Admin" and username as "kuttiadmin". The password should again be "Pass@word1".
4. In the "Partition Disks" step, choose "Manual". Select the hard disk. Create a new, empty partition table on it. Select the "Free Space" on the hard disk. Create a new partition, using the maximum space available, type Primary. Set the Bootable flag to on. Finish partitioning and write the changes to disk. _Confirm that you do not want swap space_, and continue the installation.
5. In the "Software Selection" step, choose _only_ "SSH server".
6. Install GRUB to the hard disk, and complete the installation. Reboot.
7. **Note:** To prevent history from being recorded during setup, run `unset HISTFILE` on every login from this step onwards.
8. Log on as root. Edit **/etc/default/grub**, and set the variable **GRUB_TIMEOUT** to 0. Run `update-grub`. Reboot.
9. Log on as root. Run `apt update && apt install sudo`.
10. Run `adduser kuttiadmin sudo`. 
11. Run `adduser --gecos "User 1" user1`. Set the password to **Pass@word1**.
12. Run `adduser user1 sudo`.
13. Run `visudo -f /etc/sudoers.d/kutti`. In the editor, paste `%kuttiadmin ALL=(ALL:ALL) NOPASSWD:ALL`. Save and close the file. Log out.
14. Log on as user1. Run `sudo ls` to deal with first-time sudo message. Verify that it asks for a password. Log out.
15. Log on as kuttiadmin. Run `sudo ls`. Verify that it does not ask for a password. Log out.

## For VirtualBox VM Additions

16. Log on as root. Run `apt install build-essential linux-headers-$(uname -r) dkms`
17. Insert the VM Additions CD. Run `mount /media/cdrom`.
18. Run `sh /media/cdrom/VBoxLinuxAdditions.run`. Reboot.
19. Log on as root. Run `apt remove dkms linux-headers-$(uname -r) build-essential && apt autoremove`. Reboot. Remove the VM Additions CD.

## For compacting the VM

20. Log on as root. Run `dd if=/dev/zero of=zerofillfile bs=1G`
21. Run `rm zerofillfile`. 
22. Run `poweroff`.
23. On the host, run `VBoxManage modifyhd --compact "[drive]:\[path_to_image_file]\[name_of_image_file].vdi"`.

## Install Kubernetes

24. Forward the SSH port for the installation VM. Start the VM. Copy the included **attachments/kutti-installscripts** directory  to **/home/kuttiadmin/kutti-installscripts** in the VM using `scp`. Then, copy the included **buildscripts/setup-kubernetes.sh** file to the same directory in the VM. The files should have UNIX line endings after the copy. Verify that, and rectify if needed.
25. Use SSH to log on to the installation VM as kuttiadmin. Go to the **kutti-installscripts** directory and run `chmod +x *.sh`.
26. Run `KUBE_VERSION=<version> ./setup-kubernetes.sh` to install kubernetes with containderd.
27. Verify that kubeadm is installed by running `kubeadm`. Verify the kubectl autocomplete works.

## DHClient configuration (optional)

28. Edit the file **/etc/dhcp/dhclient.conf**. Add the following to the end: `prepend domain-name-servers 1.1.1.1, 8.8.8.8;`

## motd

29. Edit the file **/etc/motd**. Replace its contents with: `Welcome to kutti.`

## Icon

30. Shut down the VM. On the host, run `VBoxManage modifyvm <name of vm> --iconfile attachments/icon/kutta.png`.

Compact the VM once more, and export to an .ova file.

## Publishing a release

Collect the .ova files for the supported versions, and create a `driver-vbox-images.json` file describing them. Then publish a GitHub release, and upload the `driver-vbox-images.json` file and the .ova files to it. Details can be found in [RELEASE.md](RELEASE.md).
