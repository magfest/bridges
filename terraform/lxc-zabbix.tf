module "zabbix" {
  source       = "./modules/lxc"
  cluster_name = "pve1"
  ip_address   = cidrhost(var.subnet, 200)
  gateway      = cidrhost(var.subnet, 1)
  cidr_mask    = local.cidr_suffix
  hostname     = "zabbix.${local.domain}"
}
