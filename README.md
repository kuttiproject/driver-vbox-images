# driver-vbox-images

amd64 VM images for the kutti Oracle VirtualBox driver

![GitHub release (latest by date)](https://img.shields.io/github/v/release/kuttiproject/driver-vbox-images?include_prereleases)

This repository contains build instructions and Packer scripts for building images for the kutti VirtualBox driver running on amd64 Linux, Windows and Mac OS. Its releases are the download source of these images for the kutti system.

## Building Images

Images can be built by manually following the instructions in [BUILDING.md](BUILDING.md), or by running the Packer scripts as detailed in [PACKER.md](PACKER.md).

## Releases

Details of creating releases can be found in [RELEASE.md](RELEASE.md).

## Release Versioning

Releases will usually follow the major and minor version number of the [driver-vbox](https://github.com/kuttiproject/driver-vbox) project. Sometimes, this repository's releases may lag by a version.

### Image Kubernetes Versions and deprecation policy

The latest release in this repository contains images for the current version of Kubernetes, and up to five versions before that. The current version and two versions before that are supported, the three before that are deprecated (you can run existing clusters created using them, but not create new clusters). Images of versions before that are deleted.

Images in releases earlier than the latest are also deleted.

## Components

The images in this repository are built from open source components. Details can be found in [COMPONENTS.md](COMPONENTS.md).

<img src="https://github.com/kuttiproject/driver-vbox-images/blob/main/attachments/icon/kutta.png?raw=true" width="32" height="32" /> Icon made by [Freepik](https://www.freepik.com) from [Flaticon](http://www.flaticon.com)
