module "dhcp" {
  source = "./modules/lxc"
  # This one weird trick. Everyone will hate it.
  cluster_name = "pve1"
  ip_address   = cidrhost(var.subnet, 253)
  gateway      = cidrhost(var.subnet, 1)
  cidr_mask    = local.cidr_suffix
  hostname     = "dhcp1.${local.domain}"
}
