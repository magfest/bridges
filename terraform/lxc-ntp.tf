module "ntp" {
  source = "./modules/lxc"
  count  = 2
  # This one weird trick. Everyone will hate it.
  cluster_name = "pve${count.index % 2 + 1}"
  ip_address   = cidrhost(var.subnet, 6 + count.index)
  cidr_mask    = local.cidr_suffix
  hostname     = "ntp${floor(count.index + 1)}.${local.domain}"
}
