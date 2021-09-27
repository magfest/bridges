terraform {
  required_version = ">= 0.13.0"
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">=2.7.4"
    }
  }
}

resource "proxmox_vm_qemu" "qemu-kvm-vm" {
  target_node = var.cluster_name
  name        = var.name
  iso         = "synology:iso/ubuntu-20.04.2-live-server-amd64.iso"
  os_type     = "ubuntu"
  memory      = var.memory
  cores       = var.cores
  agent       = 1
  hastate     = "started"
  disk { // This disk will become scsi0
    type    = "scsi"
    storage = "ceph"
    size    = var.disk_size

    //<arguments ommitted for brevity...>
  }
}

variable "disk_size" {
  description = "The name to use for all the cluster resources"
  type        = string
  default     = "16G"
}

variable "cores" {
  description = "The name to use for all the cluster resources"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Amount of memory in megabytes"
  type        = number
  default     = 4096
}

variable "name" {
  description = "Name of the vm"
  type        = string
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
  default     = "pve1"
}

variable "hostname" {
  description = "Hostname of the container"
  type        = string
}

variable "ip_address" {
  description = "IP address of host"
  type        = string
}

output "ip_address" {
  value = var.ip_address
}

output "hostname" {
  value = var.hostname
}
