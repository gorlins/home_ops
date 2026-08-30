terraform {
  required_version = "~> 1.15"
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.4"
    }
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

provider "sops" {}

data "sops_file" "secrets" {
  source_file = "secrets.enc.yaml"
}
