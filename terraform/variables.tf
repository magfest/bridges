variable "common" {
  type = map(string)
  default = {
    ssh_public_keys = <<-EOT
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMhbA0U8HF0qA8ya7icQDMxt4LUz67aHVd+ufKztbqa
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8kXJdvVCN8q1dKWKnGIsFLHKpeO7/Q9uV1C0Qtf/I8
    EOT
  }
}
variable "magcloud" {
  type = map(string)
  default = {
    network_interface = "eth0"
    bridge_id         = "vmbr999"
    cidr              = "10.101.22.0/24"
    gateway           = "10.101.22.1"
    firewall          = true
    vlan_id           = "22"
  }
}
variable "dhcp" {
  type = map(map(string))
  default = {
    dhcp1 = {
      hostname          = "dhcp1"
      target_node       = "pve1"
      vmid              = "7007"
      memory            = "1024"
      cores             = "1"
      swap              = "512"
      start             = true
      network_interface = "eth0"
      cidr              = "10.101.22.253/24"
      ostemplate        = "wowza:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
      disk_size         = "8G"
      unprivileged      = true
    },
    dhcp2 = {
      hostname          = "dhcp2"
      target_node       = "pve2"
      vmid              = "7008"
      memory            = "1024"
      cores             = "1"
      swap              = "512"
      start             = true
      network_interface = "eth0"
      cidr              = "10.101.22.254/24"
      ostemplate        = "wowza:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
      disk_size         = "8G"
      unprivileged      = true
    }
  }
}
