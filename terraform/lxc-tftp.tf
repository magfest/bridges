module "tftp" {
  source       = "./modules/lxc"
  cluster_name = "pve2"
  gateway      = cidrhost(var.subnet, 1)
  hostname     = "tftp.${local.domain}"
  nets         = [
    {
      ip   = cidrhost(var.subnet, 9)
      cidr = local.cidr_suffix
      tag  = "22"
    }
  ]
}
