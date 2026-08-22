terraform {
  required_version = "1.15.8"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0"
    }
  }

  cloud {

    organization = "soybagel"

    workspaces {
      name = "local"
    }
  }
}
