packer {
    required_plugins {
        virtualbox = {
          version = "~> 1"
          source  = "github.com/hashicorp/virtualbox"
        }
    }
}

variable "iso-url" {
  # Location of a debian netinst iso
  type    = string
}

variable "iso-checksum" {
  # Checksum of the debian netinst iso
  type    = string
}

source "virtualbox-iso" "kutti-base" {
  # Before using this script, you need to obtain a debian
  # netinst ISO, and put it in a folder called "iso".
  # The iso path and its checksum should be passed in via
  # the variables iso-url and iso-checksum.
  # E.g.:
  #   iso-url: ./iso/debian-12.10.0-amd64-netinst.iso
  #   iso-checksum: sha256:ee8d8579128977d7dc39d48f43aec5ab06b7f09e1f40a9d98f2a9d149221704a
  # The last build used debian 12.10.0.
  iso_url      = "${var.iso-url}"
  iso_checksum = "${var.iso-checksum}"

  # Create a VM with 
  #  - 2 cpu cores
  #  - 2 GiB RAM
  #  - 100 GiB hard disk
  cpus      = "2"
  memory    = "2048"
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
  # boot_command = [
  #   "<esc><wait>",
  #   "install <wait>",
  #   "DEBIAN_FRONTEND=noninteractive <wait>",
  #   "priority=critical <wait>",
  #   "fb=false <wait>",
  #   "auto=true <wait>",
  #   "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed_bookworm.cfg <wait>",
  #   "domain=kuttiproject.org <wait>",
  #   "hostname=kutti <wait>",
  #   "<enter><wait>"
  # ]
  # This is an alternative boot command, which is still
  # automatic, but keeps the UI visible so that install
  # progress can be visually tracked.
  boot_command = [
    "<esc><wait>",
    "install <wait>",
    "fb=false <wait>",
    "auto=true <wait>",
    "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed_bookworm.cfg <wait>",
    "domain=kuttiproject.org <wait>",
    "hostname=kutti <wait>",
    "<enter><wait>"
  ]


  # Although this step needs no ssh, these settings must be
  # specified.
  ssh_username = "kuttiadmin"
  ssh_password = "Pass@word1"
  ssh_timeout  = "20m"

  shutdown_command = "sudo poweroff"

  # VirtualBox 7 requires this additional setting for accessing
  # the preseed file over http. Please comment out if using
  # VirtualBox 6.
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
  ]

  # The output file should be called kutti-base.ova
  vm_name = "kutti-base"
}

build {
  sources = [
    "sources.virtualbox-iso.kutti-base"
  ]
}