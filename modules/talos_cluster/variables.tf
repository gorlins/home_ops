variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "vip" {
  description = "VIP address"
  type        = string
  default     = null
}
# variable "cluster_endpoint" {
#   description = "The endpoint for the Talos cluster"
#   type        = string
#   default     = ul
# }

variable "node_data" {
  description = "A map of node data"
  type = object({
    controlplanes = map(object({
      install_disk = optional(string, "/dev/sda")
      hostname     = optional(string)
    }))
    workers = map(object({
      install_disk = optional(string, "/dev/sda")
      hostname     = optional(string)
    }))
  })
  default = {
    controlplanes = {
      #   "10.5.0.2" = {
      #     install_disk = "/dev/sda"
      #   },
      #   "10.5.0.3" = {
      #     install_disk = "/dev/sda"
      #   },
      #   "10.5.0.4" = {
      #     install_disk = "/dev/sda"
      #   }
    }
    workers = {
      #   "10.5.0.5" = {
      #     install_disk = "/dev/nvme0n1"
      #     hostname     = "worker-1"
      #   },
      #   "10.5.0.6" = {
      #     install_disk = "/dev/nvme0n1"
      #     hostname     = "worker-2"
      #   }
    }
  }
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
