# resource "proxmox_lxc" "basic" {
#   count = 7
#   target_node  = "pve1"
#   hostname     = "wilson-${count.index}.magevent.net"
#   ostemplate   = "wowza:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
#   password     = "sorry"
#   unprivileged = true

#   // Terraform will crash without rootfs defined
#   rootfs {
#     storage = "ceph"
#     size    = "8G"
#   }

#   network {
#     name   = "eth0"
#     bridge = "vmbr999"
#     ip     = "dhcp"
#     tag    = "22"
#   }
# }
