module "cobbler" {
  source       = "./modules/lxc"
  cluster_name = "pve1"
  ip_address   = cidrhost(var.subnet, 69)
  gateway      = cidrhost(var.subnet, 1)
  cidr_mask    = local.cidr_suffix
  hostname     = "cobbler.${local.domain}"
  extra_nets   = [
    {
      ip = "10.101.69.1"
      tag = "69"
    }
  ]
}
