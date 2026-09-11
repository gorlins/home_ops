terraform {
  required_version = ">=1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.53.1"
    }
  }
}

resource "proxmox_download_file" "img" {
  node_name          = var.node_name
  content_type       = var.content_type
  datastore_id       = var.datastore_id
  file_name          = var.file_name
  url                = var.url
  checksum           = var.checksum
  checksum_algorithm = var.checksum == null ? null : var.checksum_algorithm
  overwrite          = var.overwrite

  lifecycle {
    ignore_changes = [node_name] # Assuming shared storage, no need to reupload if node changes
  }
}
