module "dhcp" {
  source       = "./modules/lxc"
  count        = 2
  # This one weird trick. Everyone will hate it.
  cluster_name = "pve${count.index % 1 + 1}"
  ip_address   = "${cidrhost(var.subnet, 253+count.index)}"
  cidr_mask    = "${local.cidr_suffix}"
  hostname     = "dhcp${floor(count.index + 1)}.${local.domain}"
}
