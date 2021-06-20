source "virtualbox-iso" "kutti-base" {
    # Before using this script, you need to obtain a debian
    # netinst ISO, and put it in a folder called "iso".
    # The iso name and its checksum should be updated here.
    # The last build used debian 10.6.0.
    iso_url = "./iso/debian-10.6.0-amd64-netinst.iso"
    iso_checksum = "md5:42c43392d108ed8957083843392c794b"

    # Create a VM with 
    #  - 2 cpu cores
    #  - 2 GiB RAM
    #  - 100 GiB hard disk
    cpus = "2"
    memory = "2048"
    disk_size = "102400"

    # Optimize for 64-bit Debian Linux
    guest_os_type = "Debian_64"

    # Guest additions will be built in the next step
    guest_additions_mode = "disable"

    # HTTP serve the preseed file
    http_directory = "buildhttp"

    # Ensure that MAC addresses are stripped at export
    export_opts = [
              "--manifest",
              "--options", "nomacs"
    ]
    format = "ova"

    # Set up a boot command for the Debian Netinst CD.
    # Important aspects are:
    #   - DEBIAN_FRONTEND and priority ensure no chatter
    #   - fb ensures no framebuffer, which we don't need
    #   - auto specifies a preseeded installation
    #   - url specifies the location of the preseed file
    #   - domain and hostname must be specified here,
    #     because an automatic installation sets up the
    #     network first, and needs these parameters to 
    #     be set in the boot command.
    # Also see the commented preseed file to see what 
    # exactly gets installed and configured.
    boot_wait = "5s"
    boot_command = [
        "<esc><wait>",
        "install <wait>",
        "DEBIAN_FRONTEND=noninteractive <wait>",
        "priority=critical <wait>",
        "fb=false <wait>",
        "auto=true <wait>",
        "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed_buster.cfg <wait>",
        "domain=kuttiproject.org <wait>",
        "hostname=kutti <wait>",
        "<enter><wait>"
    ]

    # Although this step needs no ssh, these settings must be
    # specified.
    ssh_username = "kuttiadmin"
    ssh_password = "Pass@word1"
    ssh_timeout = "20m"

    shutdown_command = "sudo poweroff"
    

    # The output file should be called kutti-base.ova
    vm_name = "kutti-base"
}

build {
    sources = [
        "sources.virtualbox-iso.kutti-base"
    ]
}