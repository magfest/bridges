module "dns" {
  source       = "./modules/lxc"
  count        = 2
  # This one weird trick. Everyone will hate it.
  cluster_name = "pve${count.index % 2 + 1}"
  ip_address   = "${cidrhost(var.subnet, 110+(count.index * 10))}"
  cidr_mask    = "${local.cidr_suffix}"
  hostname     = "dns{floor(count.index + 1)}.${local.domain}"
}
