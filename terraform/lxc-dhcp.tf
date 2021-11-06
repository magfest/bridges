module "dhcp" {
  source = "./modules/lxc"
  # This one weird trick. Everyone will hate it.
  cluster_name = "pve1"
  hostname     = "dhcp1.${local.domain}"
  gateway      = cidrhost(var.subnet, 1)
  nets         = [
    {
      ip       = cidrhost(var.subnet, 253 + count.index)
      cidr     = local.cidr_suffix
      tag      = "22"
    }
  ]
}
