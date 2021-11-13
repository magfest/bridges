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

  # I don't know if this will work...
  dynamic "network" {
    for_each = var.nets
    content {
      name     = "eth${network.key}"
      bridge   = "vmbr999"
      tag      = network.value["tag"]
      ip       = "${network.value["ip"]}/${network.value["cidr"]}"
      gw       = network.key == 0 ? var.gateway : null
    }
  }

  dynamic "mountpoint" {
    for_each = var.bindmounts
    content {
      key     = mountpoint.key
      slot    = "${mountpoint.key}"
      mp      = mountpoint.guest
      volume  = mountpoint.host
      storage = mountpoint.host
      size    = "0B"
    }
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

variable "gateway" {
  description = "IP gateway address of host"
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

variable "nets" {
  type = list(object({
    tag = string
    ip = string
    cidr = string
  }))
  description = "Additional network interface data"
}

variable "bindmounts" {
  type = list(object({
    guest = string
    host = string
  }))
  description = "Bind mounts from the host to the guest"
  default = []
}

output "ip_address" {
  value = var.nets[0].ip
}

output "hostname" {
  value = var.hostname
}
