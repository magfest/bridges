module "stackstorm1" {
  source       = "./modules/lxc"
  cluster_name = "pve1"
  ip_address   = cidrsubnet(var.subnet, 0, 136)
  hostname     = "stackstorm1.${var.branch}.magevent.net"
}

module "stackstorm2" {
  source = "./modules/lxc"
  cluster_name = "pve2"
  ip_address   = cidrsubnet(var.subnet, 0, 137)
  hostname     = "stackstorm2.${var.branch}.magevent.net"
}
