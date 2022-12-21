module "cups" {
  source       = "./modules/lxc"
  cluster_name = "pve2"
  gateway      = cidrhost(var.subnet, 1)
  hostname     = "cups.${local.domain}"
  nets = [
    {
      ip   = cidrhost(var.subnet, 13)
      cidr = local.cidr_suffix
      tag  = "22"
    }
  ]
}
