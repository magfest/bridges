terraform {
  required_version = ">= 0.13.0"
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.7.1"
    }
  }
}

resource "proxmox_vm_qemu" "qemu-kvm-vm" {
    name = "VM-name"
    target_node = "Node to create the VM on"
    iso = "synology:iso/ubuntu-20.04.2-live-server-amd64.iso"
    os_type = "ubuntu"
}

variable "name" {
  description = "Name of the vm"
  type = string
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
  default     = "pve1"
}

