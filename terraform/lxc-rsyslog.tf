module "rsyslog" {
  source       = "./modules/lxc"
  cluster_name = "pve2"
  gateway      = cidrhost(var.subnet, 1)
  hostname     = "syslog.${local.domain}"
  nets         = [
    {
      ip       = cidrhost(var.subnet, 130)
      cidr     = local.cidr_suffix
      tag      = "22"
    }
  }
}
