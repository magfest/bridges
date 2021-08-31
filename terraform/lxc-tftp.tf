module "ntp" {
  source       = "./modules/lxc"
  # This one weird trick. Everyone will hate it.
  cluster_name = "pve2"
  ip_address   = "${cidrhost(var.subnet, 9}"
  cidr_mask    = "${local.cidr_suffix}"
  hostname     = "tftp.${local.domain}"
}
