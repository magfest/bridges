terraform {
  required_version = ">= 0.13.0"
  backend "http" {
  }
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.7.1"
    }
  }
}

provider "proxmox" {
  ## TODO - FIX URL
  pm_api_url      = "https://10.101.21.41:8006/api2/json"
  pm_tls_insecure = true
  pm_log_enable   = true
  pm_log_file     = "terraform-plugin-proxmox.log"
  pm_parallel     = 1
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}

module "stackstorm1" {
  source = "./modules/lxc"
  ip_address = "10.101.22.136/24"
  hostname = "stackstorm1.magevent.net"
}

module "stackstorm2" {
  source = "./modules/lxc"
  cluster_name = "pve2"
  ip_address = "10.101.22.137/24"
  hostname = "stackstorm2.magevent.net"
}


