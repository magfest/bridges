module "dhcp" {
  source       = "./modules/lxc"
  count = 2
  cluster_name = "pve1"
  ip_address   = "${cidrhost(var.subnet, 253+count.index)}/${local.cidr_suffix}"
  hostname     = "dhcp${floor(count.index + 1)}.${local.domain}"
}
