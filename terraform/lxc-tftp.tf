module "tftp" {
  source       = "./modules/lxc"
  cluster_name = "pve2"
  ip_address   = cidrhost(var.subnet, 9)
  cidr_mask    = local.cidr_suffix
  hostname     = "tftp.${local.domain}"
}
