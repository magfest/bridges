module "rsyslog" {
  source       = "./modules/lxc"
  cluster_name = "pve2"
  ip_address   = cidrhost(var.subnet, 130)
  gateway      = cidrhost(var.subnet, 1)
  cidr_mask    = local.cidr_suffix
  hostname     = "rsyslog.${local.domain}"
}
