## Image Variables
variable "node_name" {
  description = "Name of Proxmox node to download image on, e.g. `pve`."
  type        = string
  default     = "pve-3"
}

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

variable "datastore_id" {
  description = "PVE disk location for images."
  type        = string
  default     = "cephfs"
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

variable "tags" {
  description = "Tags to add"
  type        = list(string)
  default     = null
}
