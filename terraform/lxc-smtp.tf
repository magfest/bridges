module "smtp" {
  source       = "./modules/lxc"
  cluster_name = "pve1"
  ip_address   = cidrhost(var.subnet, 23)
  gateway      = cidrhost(var.subnet, 1)
  cidr_mask    = local.cidr_suffix
  hostname     = "smtp.${local.domain}"
}
