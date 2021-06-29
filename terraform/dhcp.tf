resource "proxmox_lxc" "dhcp" {
  for_each = var.dhcp

  hostname    = each.key
  target_node = each.value.target_node
  vmid        = each.value.vmid
  memory      = each.value.memory
  cores       = each.value.cores
  swap        = each.value.swap
  start       = each.value.start
  network {
    name     = each.value.network_interface
    bridge   = each.value.bridge_id
    ip       = each.value.cidr
    gw       = each.value.gateway
    firewall = each.value.firewall
    tag      = each.value.vlan_id
  }
  ostemplate = each.value.ostemplate
  rootfs {
    storage = "ceph"
    size    = each.value.disk_size
  }
  unprivileged    = each.value.unprivileged
  ssh_public_keys = var.common.ssh_public_keys
}
