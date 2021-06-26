resource "proxmox_lxc" "dhcp" {
  for_each = var.dhcp

  hostname    = each.key
  target_node = each.value.target_node
  vmid        = each.value.vmid
  memory      = each.value.memory
  cores       = each.value.cores
  swap        = each.value.swap
  network {
    name     = each.value.network_interface
    bridge   = each.value.bridge_id
    ip       = each.value.cidr
    firewall = each.value.firewall
    tag      = each.value.vlan_id
  }
  ostemplate = each.value.ostemplate
  password   = var.common.common_password_to_be_removed
  rootfs {
    storage = "ceph"
    size    = each.value.disk_size
  }
  unprivileged = each.value.unprivileged
}
