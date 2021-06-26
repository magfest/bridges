variable "common" {
  type = map(string)
  default = {
    ssh_public_keys = <<-EOT
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMhbA0U8HF0qA8ya7icQDMxt4LUz67aHVd+ufKztbqa
    EOT
  }
}

variable "root_pass" {
  type = string
}

variable "dhcp" {
  type = map(map(string))
  default = {
    dhcp1 = {
      hostname          = "dhcp1"
      target_node       = "pve1"
      vmid              = "7007"
      memory            = "8192"
      cores             = "4"
      swap              = "512"
      start             = true
      network_interface = "eth0"
      bridge_id         = "vmbr999"
      cidr              = "10.101.22.253/24"
      gateway           = "10.101.22.1"
      vlan_id           = "22"
      firewall          = true
      ostemplate        = "wowza:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
      disk_size         = "8G"
      unprivileged      = true
    },
    dhcp2 = {
      hostname          = "dhcp2"
      target_node       = "pve2"
      vmid              = "7008"
      memory            = "8192"
      cores             = "4"
      swap              = "512"
      start             = true
      network_interface = "eth0"
      bridge_id         = "vmbr999"
      cidr              = "10.101.22.254/24"
      gateway           = "10.101.22.1"
      vlan_id           = "22"
      firewall          = true
      ostemplate        = "wowza:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
      disk_size         = "8G"
      unprivileged      = true
    }
  }
}
