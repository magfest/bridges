module "dns" {
  source = "./modules/lxc"
  count  = 2
  # This one weird trick. Everyone will hate it.
  cluster_name = "pve${count.index % 2 + 1}"
  gateway      = cidrhost(var.subnet, 1)
  hostname     = "dns${floor(count.index + 1)}.${local.domain}"
  nets = [
    {
      ip   = cidrhost(var.subnet, 110 + (count.index * 10))
      cidr = local.cidr_suffix
      tag  = "22"
    }
  ]
}
