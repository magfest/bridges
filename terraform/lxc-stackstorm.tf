module "stackstorm1" {
  source = "./modules/lxc"
  ip_address = "10.101.22.136/24"
  hostname = "stackstorm1.dev.magevent.net"
}

module "stackstorm2" {
  source = "./modules/lxc"
  cluster_name = "pve2"
  ip_address = "10.101.22.137/24"
  hostname = "stackstorm2.dev.magevent.net"
}
