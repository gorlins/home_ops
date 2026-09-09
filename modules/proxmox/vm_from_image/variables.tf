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


variable "full_clone" {
  description = "Create a full independent clone; setting to `false` will create a linked clone."
  type        = bool
  default     = true
}

variable "wait_for_ip_ipv4" {
  description = "Wait for at least one non-loopback, non-link-local IPv4 address before considering the VM ready."
  type        = bool
  default     = false
}

variable "wait_for_ip_ipv6" {
  description = "Wait for at least one non-loopback, non-link-local IPv6 address before considering the VM ready."
  type        = bool
  default     = false
}

variable "tablet" {
  description = "Enable tablet for pointer."
  type        = bool
  default     = false
}

variable "display_type" {
  type    = string
  default = "std"
}

variable "display_memory" {
  type    = number
  default = 16
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

variable "numa_cpus" {
  type    = string
  default = null
}

variable "numa_memory" {
  type    = string
  default = null
}

variable "numa_hostnodes" {
  type    = string
  default = null
}

variable "numa_policy" {
  type    = string
  default = "preferred"
}

### Disk Variables
variable "scsihw" {
  description = "Storage controller, e.g. `virtio-scsi-pci`."
  type        = string
  default     = "virtio-scsi-pci"
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

variable "efi_disk_format" {
  description = "EFI disk storage format."
  type        = string
  default     = "raw"
}

variable "efi_disk_type" {
  description = "EFI disk OVMF firmware version."
  type        = string
  default     = "4m"
}

variable "efi_disk_pre_enrolled_keys" {
  description = "EFI disk enable pre-enrolled secure boot keys."
  type        = bool
  default     = true
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
variable "vnic_model" {
  description = "Networking adapter model, e.g. `virtio`."
  type        = string
  default     = "virtio"
}

variable "vnic_bridge" {
  description = "Networking adapter bridge, e.g. `vmbr0`."
  type        = string
  default     = "vmbr0"
}

variable "vlan_tag" {
  description = "Networking adapter VLAN tag."
  type        = number
  default     = null
}

### Cloud-init Variables
variable "ci_datastore_id" {
  description = "Disk storage location for the cloud-init disk."
  type        = string
  default     = "local-lvm"
}

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

variable "ci_dns_domain" {
  description = "DNS domain name, e.g. `example.com`. Default `null` value will use PVE host settings."
  type        = string
  default     = null
}

variable "ci_dns_server" {
  description = "DNS server, e.g. `192.168.1.1`. Default `null` value will use PVE host settings."
  type        = string
  default     = null
}

variable "ci_ipv4_cidr" {
  description = "Default uses DHCP, for a static address set CIDR, e.g. `192.168.1.254/24`."
  type        = string
  default     = "dhcp"
}

variable "ci_ipv4_gateway" {
  description = "Default `null` will use `DHCP`, for a static address add IP, e.g. `192.168.1.1`."
  type        = string
  default     = null
}

variable "ci_meta_data" {
  description = "Add a custom cloud-init `meta` configuration file, e.g `local:snippets/meta-data.yaml`."
  type        = string
  default     = null
}

variable "ci_network_data" {
  description = "Add a custom cloud-init `network` configuration file, e.g `local:snippets/network-data.yaml`."
  type        = string
  default     = null
}

variable "ci_user_data" {
  description = "Add a custom cloud-init `user` configuration file, e.g `local:snippets/user-data.yaml`."
  type        = string
  default     = null
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

variable "migrate" {
  description = "Migrate clone to new node, rather than recreating, when node changes"
  type        = bool
  default     = true
}
