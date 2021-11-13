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
  ]
# THIS DOESN'T WORK RIGHT NOW:
# Proxmox doesn't currently allow anyone but the root user to create bindmounts.
# We're not authenticating to Proxmox using root currently.
#  bindmounts = [
#    {
#      guest = "/var/log/remote"
#      host  = "/mnt/pve/syslog/remote/${var.branch}/"
#    }
#  ]
}
