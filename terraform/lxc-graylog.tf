module "graylog" {
  source       = "./modules/lxc"
  cluster_name = "pve1"
  gateway      = cidrhost(var.subnet, 1)
  hostname     = "graylog.${local.domain}"
  memory       = 4096
  nets         = [
    {
      ip   = cidrhost(var.subnet, 129)
      cidr = local.cidr_suffix
      tag  = "22"
    }
  ]
}
