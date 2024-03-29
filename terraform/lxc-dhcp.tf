module "dhcp" {
  source       = "./modules/lxc"
  cluster_name = "pve1"
  hostname     = "dhcp1.${local.domain}"
  gateway      = cidrhost(var.subnet, 1)
  nets = [
    {
      ip   = cidrhost(var.subnet, 4)
      cidr = local.cidr_suffix
      tag  = local.branch_vlan
    }
  ]
}
