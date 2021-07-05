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
PLUGIN_ARCH="linux_amd64"
PLUGIN_VERSION="2.7.2"
PLUGIN_TARGET="~/.terraform.d/plugins/registry.magevent.net/yesrod/proxmox/${PLUGIN_VERSION}/${PLUGIN_ARCH}/"

# Cleanup
go clean -modcache

# Clone the repo
git clone https://github.com/yesrod/terraform-provider-proxmox.git
cd terraform-provider-proxmox

# Build the plugin
export GO111MODULE=on
go get github.com/yesrod/proxmox-api-go@642e015
make clean
make build

# Create the directory holding the newly built Terraform plugins
mkdir -p "${PLUGIN_TARGET}"
cp bin/terraform-provider-proxmox "${PLUGIN_TARGET}"
echo "Installed to ${PLUGIN_TARGET}"
ls -halt "${PLUGIN_TARGET}"

# Run initial... init
terraform init