module "dhcp1" {
  source       = "./modules/lxc"
  cluster_name = "pve1"
  ip_address   = "${cidrhost(var.subnet, 253)}/${local.cidr_suffix}"
  hostname     = "dhcp1.${local.domain}"
}

module "dhcp2" {
  source       = "./modules/lxc"
  cluster_name = "pve2"
  ip_address   = "${cidrhost(var.subnet, 254)}/${local.cidr_suffix}"
  hostname     = "dhcp2.${local.domain}"
}
