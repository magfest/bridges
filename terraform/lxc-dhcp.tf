module "dhcp1" {
  source     = "./modules/lxc"
  cluster_name = "pve1"
  ip_address   = cidrsubnet(var.subnet, 0, 253)
  hostname     = "dhcp1.${var.branch}.magevent.net"
}

module "dhcp2" {
  source       = "./modules/lxc"
  cluster_name = "pve2"
  ip_address   = cidrsubnet(var.subnet, 0, 254)
  hostname     = "dhcp2.${var.branch}.magevent.net"
}
