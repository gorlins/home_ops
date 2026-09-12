## VM Variables
variable "node_name" {
  description = "Name of Proxmox node to provision VM on, e.g. `pve`."
  type        = string
}

variable "boot_disk" {
  description = "Details for the boot disk"
  type = object({
    interface = optional(string, "scsi0")
    size      = optional(number, 32)
    cache     = optional(string)
    iothread  = optional(bool, true)
    ssd       = optional(bool, true)
    discard   = optional(string, "on")
  })
  default = {}
}

variable "img_datastore_id" {
  description = "Target data storage for the image"
  default     = "cephfs"
}

variable "datastore_id" {
  description = "Target data storage for all disks"
  default     = "cephy"
}

variable "vm_id" {
  description = "ID number for new VM."
  type        = number
  default     = null
}

variable "name" {
  description = "VM name, must be alphanumeric (may contain dash: `-`). Defaults to using PVE naming, e.g. 'Copy-of-VM-<template_name>'."
  type        = string
  default     = null
}

variable "description" {
  description = "VM description."
  type        = string
  default     = null
}

variable "tags" {
  description = "Proxmox tags for the VM."
  type        = list(string)
  default     = []
}

variable "agent" {
  description = "Enable QEMU guest agent."
  type        = bool
  default     = true
}

variable "bios" {
  description = "VM bios, setting to `ovmf` will automatically create a EFI disk."
  type        = string
  default     = "ovmf"
  validation {
    condition     = contains(["seabios", "ovmf"], var.bios)
    error_message = "Invalid bios setting: ${var.bios}. Valid options: 'seabios' or 'ovmf'."
  }
}

variable "operating_system" {
  description = "The Operating System configuration. type"
  type        = string
  default     = "l26"
}

variable "machine" {
  description = "Hardware layout for the VM, `q35` or `x440i`."
  type        = string
  default     = "q35"
  validation {
    condition     = contains(["q35", "x440i"], var.machine)
    error_message = "Unknown machine setting."
  }
}
variable "rng_source" {
  description = "The file on the host to gather entropy from"
  type        = string
  default     = "/dev/urandom"
}

### Disk Variables
variable "scsi_hardware" {
  description = "Storage controller, e.g. `virtio-scsi-pci`."
  type        = string
  default     = "virtio-scsi-single"
}

### Cloud-init Variables
variable "user_account" {
  description = "Credentials for cloud init user"
  type = object({
    username = optional(string)
    password = optional(string)
    keys     = optional(list(string))
  })
  sensitive = true
  default   = {}
}

variable "vendor_data_file_id" {
  description = "Add a custom cloud-init `vendor` configuration file, e.g `local:snippets/vendor-data.yaml`."
  type        = string
  default     = null
}


# Image vars
variable "file_name" {
  description = "Filename, default `null` will extract name from URL."
  type        = string
  default     = null
}

variable "url" {
  description = "Image URL."
  type        = string
}

variable "checksum" {
  description = "Image checksum value."
  type        = string
  default     = null
}

variable "checksum_algorithm" {
  description = "Image checksum algorithm."
  type        = string
  default     = "sha256"
  validation {
    condition     = contains(["md5", "sha1", "sha224", "sha256", "sha384", "sha512"], var.checksum_algorithm)
    error_message = "Invalid checksum setting: ${var.checksum_algorithm}."
  }
}

variable "content_type" {
  description = "File content type, `iso` for VM images or `vztmpl` for LXC images."
  type        = string
  default     = "import"
  validation {
    condition     = contains(["iso", "vztmpl", "import"], var.content_type)
    error_message = "Invalid content type: ${var.content_type}."
  }
}

variable "overwrite" {
  description = "Overwrite pre-existing image on PVE host."
  type        = bool
  default     = false
}
