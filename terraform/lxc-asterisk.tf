module "asterisk" {
  source       = "./modules/lxc"
  cluster_name = "pve1"
  hostname     = "asterisk.${local.domain}"
  gateway      = cidrhost(var.subnet, 1)
  nets = [
    {
      ip   = cidrhost(var.subnet, 12)
      cidr = local.cidr_suffix
      tag  = local.branch_vlan
    }
  ]
}
