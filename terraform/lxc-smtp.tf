module "smtp" {
  source       = "./modules/lxc"
  cluster_name = "pve1"
  gateway      = cidrhost(var.subnet, 1)
  hostname     = "smtp.${local.domain}"
  nets = [
    {
      ip   = cidrhost(var.subnet, 23)
      cidr = local.cidr_suffix
      tag  = local.branch_vlan
    }
  ]
}
