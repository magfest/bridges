module "stackstorm1" {
  source       = "./modules/lxc"
  cluster_name = "pve1"
  ip_address   = "${cidrhost(var.subnet, 136)}/${local.cidr_suffix}"
  hostname     = "stackstorm1.${local.domain}"
}

module "stackstorm2" {
  source = "./modules/lxc"
  cluster_name = "pve2"
  ip_address   = "${cidrhost(var.subnet, 137)}/${local.cidr_suffix}"
  hostname     = "stackstorm2.${local.domain}"
}
