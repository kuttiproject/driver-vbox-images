variable "kube-version" {
    type = string
    default = env("KUBE_VERSION")
}

variable "vm-version" {
    type = string
    default = "latest"
}

variable "vm-description" {
    type = string
    default = "Kutti VirtualBox Image"
}

source "virtualbox-ovf" "kutti-vbox" {
    source_path = "./output-kutti-base/kutti-base.ova"
    checksum = "none"

    ssh_username = "kuttiadmin"
    ssh_password = "Pass@word1"
    ssh_timeout = "20m"

    shutdown_command = "sudo poweroff"

    # Guest additions will be built in this step. So,
    # the guest additions ISO should be attached as a
    # CD device during build.
    guest_additions_mode = "attach"

    # When the OVA created by the previous step is 
    # imported, the disk needs to be imported in VDI
    # format. This will allow us to compact it after
    # finishing setup, thus reducing the size of the
    # final OVA.
    import_flags = [
        "--vsys",
        "0",
        "--unit",
        "10",
        "--disk",
        "output-kutti-vbox/kutti-vbox-disk001.vdi"
    ]

    # After all provisioners have run, and the VM has
    # been stopped, the following VBoxManage commands
    # are carried out. The first one compacts the VDI
    # hard disk, and the second one adds an icon to 
    # the VM image.
    vboxmanage_post = [
        [
            "modifyhd",
            "--compact",
            "output-kutti-vbox/kutti-vbox-disk001.vdi"
        ],
        [
            "modifyvm",
            "{{ .Name }}",
            "--iconfile",
            "attachments/icon/kutta.png"
        ]
    ]

    # Ensure that MAC addresses are stripped at export
    export_opts = [
        "--manifest",
        "--options", "nomacs",
        "--vsys", "0",
        "--description", "${ var.vm-description }",
        "--version", "${ var.vm-version }"
    ]
    format = "ova"

    # The output file should be called kutti-vbox.ova
    vm_name = "kutti-vbox"

    headless = true
}

build {
    sources = [
        "sources.virtualbox-ovf.kutti-vbox"
    ]

    provisioner "shell" {
        # The setup-base script sets up:
        #   - VirtualBox Guest Additions
        #   - GRUB settings
        #   - Some system utilities
        #   - containerd
        # The setup-kubernetes script sets up
        # kubelet, kubeadm and kubectl. The 
        # variable KUBE_VERSION controls which
        # version gets set up. Its value must
        # match the apt pin version published 
        # in the google debian repositry for 
        # Kubernetes. If it is left blank, the
        # latest version is used.
        scripts = [
            "buildscripts/setup-base.sh",
            "buildscripts/setup-kubernetes.sh"
        ]
        # These scripts must be run with sudo access
        execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
        valid_exit_codes = [0,2,2300218]
        expect_disconnect = true

        # Ensure the KUBE_VERSION variable.
        environment_vars = [
            "KUBE_VERSION=${ var.kube-version }"
        ]
    }

    provisioner "file" {
        # Files in the kutti-installscripts folder 
        # define the interface between the driver
        # and the OS in the VMs.
        sources = [
            "attachments/kutti-installscripts/"
        ]

        destination = "/home/kuttiadmin/kutti-installscripts"
    }

    provisioner "shell" {
        # The process-scripts script processes the
        # the tools installed in the prior step as
        # follows:
        #   * converts line endings to Linux/UNIX
        #   * makes them executable
        #   * makes symbolic links in /usr/local/bin.
        # The cleanup script removes unneeded stuff.
        # The stamp-kuttirelease script creates a
        # file /etc/kutti-release, which contains
        # the versions of the components.
        # The pre-compact script fills the VM hard
        # disk with zeroes, and the deletes the file.
        # This allows VirtualBox to compact the disk.
        scripts = [
            "buildscripts/process-scripts.sh",
            "buildscripts/cleanup.sh",
            "buildscripts/stamp-kuttirelease.sh",
            "buildscripts/pre-compact.sh"
        ]
        # These scripts must be run with sudo access
        execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"

        # Ensure the VM_VERSION variable.
        environment_vars = [
            "VM_VERSION=${ var.vm-version }"
        ]
    }
}