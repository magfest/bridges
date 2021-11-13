module "librenms" {
  source       = "./modules/lxc"
  cluster_name = "pve1"
  gateway      = cidrhost(var.subnet, 1)
  hostname     = "librenms-21.${local.domain}"
  nets = [
    {
      ip   = cidrhost(var.subnet, 151)
      cidr = local.cidr_suffix
      tag  = "22"
    }
  ]
}
