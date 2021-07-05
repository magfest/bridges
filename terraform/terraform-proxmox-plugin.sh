#!/bin/bash
#
# Grab and install my version of the Terraform plugin until the HA State fix 
# for containers is merged upstream and released.
#
# We should be able to adapt this to handle the intermediate period between 
# merge and release from the upstream repository as well.
#
# - yesrod
#
PLUGIN_ARCH=linux_amd64

# Clone the repo
git clone https://github.com/yesrod/terraform-provider-proxmox.git
cd terraform-provider-proxmox

# Build the plugin
export GO111MODULE=on
go install github.com/yesrod/terraform-provider-proxmox/cmd/terraform-provider-proxmox
make build

# Create the directory holding the newly built Terraform plugins
mkdir -p ~/.terraform.d/plugins/registry.magevent.net/telmate/proxmox/2.7.2/${PLUGIN_ARCH}
cp bin/terraform-provider-proxmox ~/.terraform.d/plugins/registry.magevent.net/telmate/proxmox/2.7.2/${PLUGIN_ARCH}/