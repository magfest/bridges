module "nginx-proxy" {
  source       = "./modules/lxc"
  cluster_name = "pve2"
  gateway      = cidrhost(var.subnet, 1)
  hostname     = "nginx-proxy.${local.domain}"
  nets = [
    {
      ip   = cidrhost(var.subnet, 30)
      cidr = local.cidr_suffix
      tag  = "22"
    }
  ]
}
