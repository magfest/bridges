terraform {
  required_version = ">= 0.13.0"
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">=2.7.4"
    }
  }
}

resource "proxmox_lxc" "lxc-container" {
  target_node     = var.cluster_name
  ostemplate      = "wowza:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
  unprivileged    = true
  hostname        = var.hostname
  memory          = var.memory
  cores           = "1"
  swap            = "512"
  start           = true
  hastate         = "started"
  ssh_public_keys = <<-EOT
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMhbA0U8HF0qA8ya7icQDMxt4LUz67aHVd+ufKztbqa
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8kXJdvVCN8q1dKWKnGIsFLHKpeO7/Q9uV1C0Qtf/I8
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHiKbjWHf/hfmD5ArZek3BnKaLf56L3dBqovisvlABw
EOT

  rootfs {
    storage = "ceph"
    size    = var.size
  }

  network {
    name   = "eth0"
    bridge = "vmbr999"
    tag    = "22"
    ip     = "${var.ip_address}/${var.cidr_mask}"
    gw     = var.gateway
  }

  # I don't know if this will work...
  network {
    for_each = extra_nets
    name     = "eth${extra_nets.key}"
    bridge   = "vmbr999"
    tag      = extra_nets.tag
    ip       = "${extra_nets.ip}/${extra_nets.cidr}"
  }

}

variable "hostname" {
  description = "Hostname of the container"
  type        = string
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
  default     = "pve1"
}

variable "ip_address" {
  description = "IP address of host"
  type        = string
}

variable "gateway" {
  description = "IP gateway address of host"
  type        = string
}

variable "cidr_mask" {
  description = "CIDR for IP subnet"
  type        = string
}

variable "size" {
  description = "Size of fs in gigabytes"
  type        = string
  default     = "8G"
}

variable "memory" {
  description = "Size of memory in megabytes"
  type        = string
  default     = "512"
}

variable "extra_nets" {
  type = list(object({
    tag = string
    ip = string
    cidr = string
  }))
  description = "Additional network interface data"
  default = null
}

output "ip_address" {
  value = var.ip_address
}

output "hostname" {
  value = var.hostname
}
