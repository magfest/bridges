module "ntp" {
  source = "./modules/lxc"
  count  = 2
  # This one weird trick. Everyone will hate it.
  cluster_name = "pve${count.index % 2 + 1}"
  gateway      = cidrhost(var.subnet, 1)
  hostname     = "ntp${floor(count.index + 1)}.${local.domain}"
  nets         = [
    {
      ip   = cidrhost(var.subnet, 6 + count.index)
      cidr = local.cidr_suffix
      tag  = "22"
    }
  ]
}
