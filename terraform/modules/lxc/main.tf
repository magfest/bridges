terraform {
  required_version = ">= 0.13.0"
  required_providers = {
    proxmox {
      source  = "Telmate/proxmox"
      version = "2.7.1"
    }
  }
}

resource "proxmox_lxc" "lxc-container" {
  target_node  = var.cluster_name
  ostemplate   = "wowza:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
  unprivileged = true
  hostname = var.hostname

  rootfs {
    storage = "ceph"
    size    = var.size
  }

  network {
    name   = "eth0"
    bridge = "vmbr999"
    tag    = "22"
    ip     = var.ip_address
  }
}

variable "hostname" {
  description = "Hostname of the container"
  type = string
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

variable "size" {
  description = "Size of fs in gigabytes"
  type        = string
  default = "8G"
}

