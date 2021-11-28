module "laptops" {
  source       = "./modules/lxc"
  cluster_name = "pve1"
  gateway      = cidrhost(var.subnet, 1)
  hostname     = "laptops.${local.domain}"
  nets = [
    {
      ip   = cidrhost(var.subnet, 69)
      cidr = local.cidr_suffix
      tag  = "22"
    },
    {
      ip   = "10.101.69.${split(".", var.subnet)[2] - 20}"
      cidr = "24"
      tag  = "69"
    }
  ]
}
