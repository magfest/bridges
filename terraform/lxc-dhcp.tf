module "dhcp" {
  source = "./modules/lxc"
  count  = 2
  # This one weird trick. Everyone will hate it.
  cluster_name = "pve${count.index % 2 + 1}"
  ip_address   = cidrhost(var.subnet, 253 + count.index)
  gateway      = cidrhost(var.subnet, 1)
  cidr_mask    = local.cidr_suffix
  hostname     = "dhcp${floor(count.index + 1)}.${local.domain}"
}
