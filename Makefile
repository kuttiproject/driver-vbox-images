VERSION_MAJOR ?= 0
VERSION_MINOR ?= 2
BUILD_NUMBER  ?= 4
PATCH_NUMBER  ?= 
VERSION_STRING = $(VERSION_MAJOR).$(VERSION_MINOR).$(BUILD_NUMBER)$(PATCH_NUMBER)

OS_ISO_PATH ?= "iso/debian-10.6.0-amd64-netinst.iso"
OS_ISO_CHECKSUM ?= "md5:42c43392d108ed8957083843392c794b"

KUBE_VERSION ?=
KUBE_VERSION_DESCRIPTION = $(or $(KUBE_VERSION),"latest")

define VM_DESCRIPTION
Kutti VirtualBox Image version $(VERSION_STRING)

Debian base image: $(OS_ISO_PATH)
Kubernetes version: $(KUBE_VERSION_DESCRIPTION)
endef
export VM_DESCRIPTION

.PHONY: usage
usage:
	@echo "Usage: make step1|step2|clean-step1|clean-step2|clean"

output-kutti-base/kutti-base.ova: kutti.step1.pkr.hcl
	packer build -var "iso-url=$(OS_ISO_PATH)" -var "iso-checksum=$(OS_ISO_CHECKSUM)" $<

output-kutti-vbox/kutt-vbox.ova: kutti.step2.pkr.hcl output-kutti-base/kutti-base.ova
	packer build -var "vm-version=$(VERSION_STRING)" -var "vm-description=$$VM_DESCRIPTION" $<

.PHONY: step1
step1: output-kutti-base/kutti-base.ova

.PHONY: step2
step2: output-kutti-vbox/kutt-vbox.ova

.PHONY: all
all: step1 step2

.PHONY: clean-step1
clean-step1:
	rm -r output-kutti-base/

.PHONY: clean-step2
clean-step2:
	rm -r output-kutti-vbox/

.PHONY: clean
clean: clean-step2 clean-step1