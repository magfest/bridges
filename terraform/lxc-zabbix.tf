module "zabbix" {
  source       = "./modules/lxc"
  cluster_name = "pve1"
  gateway      = cidrhost(var.subnet, 1)
  hostname     = "zabbix-new.${local.domain}"
  nets = [
    {
      ip   = cidrhost(var.subnet, 201)
      cidr = local.cidr_suffix
      tag  = "22"
    }
  ]
}
