module "graylog" {
  source       = "./modules/lxc"
  cluster_name = "pve1"
  ip_address   = cidrhost(var.subnet, 129)
  gateway      = cidrhost(var.subnet, 1)
  cidr_mask    = local.cidr_suffix
  hostname     = "graylog.${local.domain}"
  memory       = 4096
}
