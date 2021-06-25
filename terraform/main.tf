terraform {
  backend "http" {
  }
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.7.1"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://pve1.magevent.net:8006/api2/json",
  pm_tls_insecure = true
  pm_log_enable = true
  pm_log_file = "terraform-plugin-proxmox.log"
  pm_log_levels = {
    _default = "debug"
    _capturelog = ""
  }
}
