module "nebula" {
  source       = "./modules/lxc"
  cluster_name = "pve2"
  gateway      = cidrhost(var.subnet, 1)
  hostname     = "local-nebula.${local.domain}"
  nets = [
    {
      ip   = cidrhost(var.subnet, 31)
      cidr = local.cidr_suffix
      tag  = local.branch_vlan
    }
  ]
}
