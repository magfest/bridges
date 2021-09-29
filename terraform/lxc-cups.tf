module "cups" {
  source       = "./modules/lxc"
  cluster_name = "pve2"
  ip_address   = cidrhost(var.subnet, 13)
  gateway      = cidrhost(var.subnet, 1)
  cidr_mask    = local.cidr_suffix
  hostname     = "cups.${local.domain}"
}
