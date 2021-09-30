module "zabbix" {
  source       = "./modules/lxc"
  cluster_name = "pve1"
  ip_address   = cidrhost(var.subnet, 201)
  gateway      = cidrhost(var.subnet, 1)
  cidr_mask    = local.cidr_suffix
  hostname     = "zabbix-new.${local.domain}"
}
