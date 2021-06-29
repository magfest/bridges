resource "proxmox_lxc" "basic" {
  count = 1
  target_node  = "pve1"
  hostname     = "provisioning-template-${count.index}.magevent.net"
  ostemplate   = "wowza:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
  ssh_public_keys = var.common.ssh_public_keys
  unprivileged = true

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "ceph"
    size    = "8G"
  }

  network {
    name   = "eth0"
    ip     = "dhcp"
    bridge   = var.network.magcloud.bridge_id
    gw       = var.network.magcloud.gateway
    firewall = var.network.magcloud.firewall
    tag      = var.network.magcloud.vlan_id
  }
}
