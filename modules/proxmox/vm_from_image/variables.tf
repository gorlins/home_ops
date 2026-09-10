## VM Variables
variable "import_from" {
  description = "Reference to import image (<datastore_id>:<content_type>/<file_name>)"
  type        = string
}

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

variable "datastore_id" {
  description = "Target data storage for all disks"
  default     = "local-lvm"
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
variable "on_boot" {
  description = "Whether to start the VM on node boot"
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

variable "cpu_sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = null
}

variable "cpu_cores" {
  description = "Number of CPU cores."
  type        = number
  default     = null
}

variable "cpu_type" {
  description = "CPU type."
  type        = string
  default     = null
}

variable "memory" {
  description = "Memory size in `MiB`."
  type        = number
  default     = null
}

variable "memory_floating" {
  description = "Minimum memory size in `MiB`, setting this value enables memory ballooning."
  type        = number
  default     = null
}

### Disk Variables
variable "scsi_hardware" {
  description = "Storage controller, e.g. `virtio-scsi-pci`."
  type        = string
  default     = "virtio-scsi-single"
}

variable "additional_disks" {
  type = list(object({
    interface = string
    size      = number
    cache     = optional(string)
    iothread  = optional(bool, true)
    ssd       = optional(bool, true)
    discard   = optional(string, "on")
    }
  ))
  default = []
}

### Network Variables
variable "network_devices" {
  description = "List of nics"
  type = list(object({
    bridge  = optional(string)
    model   = optional(string)
    mtu     = optional(number)
    vlan_id = optional(number)
    address = optional(string, "dhcp")
  }))
  default = [{}]
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

### Timeout Variables
variable "timeout_clone" {
  description = "Timeout in seconds for cloning a VM."
  type        = number
  default     = 1800
}

variable "timeout_create" {
  description = "Timeout in seconds for creating a VM."
  type        = number
  default     = 1800
}

variable "timeout_migrate" {
  description = "Timeout in seconds for migrating a VM."
  type        = number
  default     = 1800
}

variable "timeout_reboot" {
  description = "Timeout in seconds for rebooting a VM."
  type        = number
  default     = 1800
}

variable "timeout_shutdown_vm" {
  description = "Timeout in seconds for shutting down a VM."
  type        = number
  default     = 1800
}

variable "timeout_start_vm" {
  description = "Timeout in seconds for starting a VM."
  type        = number
  default     = 1800
}

variable "timeout_stop_vm" {
  description = "Timeout in seconds for stopping a VM."
  type        = number
  default     = 300
}

variable "template" {
  description = "Whether image should be turned into a template"
  type        = bool
  default     = false
}
