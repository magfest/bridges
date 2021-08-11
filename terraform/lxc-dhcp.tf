module "dhcp1" {
  source     = "./modules/lxc"
  ip_address = "10.101.23.253/24"
  hostname   = "dhcp1.dev.magevent.net"
}

module "dhcp2" {
  source       = "./modules/lxc"
  cluster_name = "pve2"
  ip_address   = "10.101.23.254/24"
  hostname     = "dhcp2.dev.magevent.net"
}
