resource "proxmox_lxc" "basic" {
  target_node  = "pve1"
  hostname     = "wilson"
  ostemplate   = "wowza:vztmpl/ubuntu-18.04-standard_18.04.1-1_amd64.tar.gz"
  password     = "sorry"
  unprivileged = true

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "ceph"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr999"
    ip     = "dhcp"
    tag    = "22"
  }
}
