terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.53.1"
    }
  }
}

module "img" {
  source = "../shared_image"

  node_name          = var.node_name
  datastore_id       = var.img_datastore_id
  content_type       = var.content_type
  file_name          = var.file_name
  url                = var.url
  checksum           = var.checksum
  checksum_algorithm = var.checksum == null ? null : var.checksum_algorithm
  overwrite          = var.overwrite
}

module "template" {
  source      = "../vm_from_image"
  import_from = module.img.id
  node_name   = var.node_name
  vm_id       = var.vm_id
  name        = var.name
  description = var.description
  tags        = var.tags

  # Required for template to work correctly
  migrate  = true
  template = true
  started  = false

  # Machine config
  bios             = var.bios
  machine          = var.machine
  scsi_hardware    = var.scsi_hardware
  boot_disk        = var.boot_disk
  operating_system = var.operating_system

  datastore_id = var.datastore_id
  rng_source   = var.rng_source

  # VM config
  agent               = var.agent
  vendor_data_file_id = var.vendor_data_file_id
  user_account        = var.user_account
}
