variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "talos_version" {
  type    = string
  default = "v1.13.9"
}

variable "schematic_id" {
  description = "Default schematic id for nodes, unless overridden"
  type        = string
  default     = null
}

variable "vip" {
  description = "VIP address"
  type        = string
  default     = null
}

variable "nodes" {
  description = "List of node data"
  type = map(object({
    install_disk = optional(string, "/dev/sda")
    hostname     = optional(string)
    schematic_id = optional(string)
    secureboot   = optional(bool, false)
    controlplane = optional(bool, false)
    patches      = optional(list(string), [])
    platform     = optional(string, "metal")
  }))
}

variable "global_patches" {
  type    = list(string)
  default = []
}

variable "controlplane_patches" {
  type    = list(string)
  default = []
}

variable "worker_patches" {
  type    = list(string)
  default = []
}
