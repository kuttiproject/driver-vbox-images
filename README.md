# driver-vbox-images
VM images for the kutti Oracle VirtualBox driver

![GitHub release (latest by date)](https://img.shields.io/github/v/release/kuttiproject/driver-vbox-images?include_prereleases)

This repository contains build instructions and Packer scripts for building images for the kutti VirtualBox driver. For now, its releases are the download source of these images for the kutti system.

## Release Versioning
Releases will follow the major and minor version number of the [driver-vbox](https://github.com/kuttiproject/driver-vbox) project, and vice versa.

## Kubernetes Versions
We will try and maintain images for the current Kubernetes version, and two earlier minor versions. Versions older than that will be deprecated, but not removed. In time, there will be a strategy for image removal.

## Building Images
Images can be built by manually following the instructions in BUILDING.md, or by running the Packer scripts as detailed in PACKER.md.

## Components
The images in this repository are built from open source components. Details can be found in COMPONENTS.md.


Icon made by [Freepik](https://www.freepik.com) from [Flaticon](http://www.flaticon.com)
