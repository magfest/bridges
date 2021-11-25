# Laptops

Provisioning of laptops is done by a specific container or VM with the `laptop_images` role.  This guest provides DHCP and TFTP services on a specific subnet, and is configured to provide installation over PXE for Ubuntu and Windows laptops.

## Prerequisites
First, the guest needs to exist.  Currently, the guest in question is an LXC container named `laptops` that has an extra interface, `eth1`, on VLAN 69.  

The `laptop_images` role expects the guest to have two interfaces, or at least one interface named `eth1`.  The DHCP server will only listen on that specific interface to prevent horrible accidents like accidentally provisioning all the rack hardware.  That interface should be on a separate VLAN accordingly.

Once that guest exists, the provisioning VLAN (currently VLAN 69 ) needs to be added to the Proxmox server trunks and exposed via a physical port on the rack core switch.  This port should be connected to a bunch of dumb switches (or smart switches with a flat network configuration) to provide ports for laptop provisioning.

## Usage
Hook a laptop into a free provisioning switch port via Ethernet, boot the laptop, and find the laptop's boot menu key (usually F11 or F12).  

Once you're in the boot menu, find the network boot option - it'll be named something like "PXE", "NIC", or "Network Boot".  Select that option and wait.  You'll get a boot menu after a bit where you can select Ubuntu or Windows.  

Once you make your selection, the laptop will begin automatic installation.