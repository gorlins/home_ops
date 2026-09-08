ephemeral "sops_file" "secrets" {
  source_file = "secrets.enc.yaml"
  input_type  = "yaml"
}

data "sops_file" "secrets" {
  # ephemeral should be used where possible, but this file is used for everything else
  source_file = "terraform_data_secrets.enc.yaml"
  input_type  = "yaml"
}

provider "proxmox" {
  endpoint  = ephemeral.sops_file.secrets.data["proxmox.endpoint"]
  api_token = join("=", [ephemeral.sops_file.secrets.data["proxmox.token_id"], ephemeral.sops_file.secrets.data["proxmox.secret"]])
  # api_token = "blog_example@pam!terraform=your-api-token-secret"
  insecure = false # set to false if using a valid TLS certificate
  ssh {
    agent    = true
    username = "root" # Ensure this is NOT empty ""
  }
}

locals {
  local_datastore  = "local_vols"
  shared_datastore = "cephy"
  shared_fs        = "cephfs"

  ci_username = data.sops_file.secrets.data["ci.username"]
  ci_password = data.sops_file.secrets.data["ci.password"]
  # sops provider can't read arrays for some reason - parse it manually
  ci_keys = yamldecode(data.sops_file.secrets.raw)["ci"]["keys"]
}

# Create a custom cloud-init config using BPG provider
resource "proxmox_virtual_environment_file" "cloud_vendor_config" {
  node_name    = "pve-3"
  datastore_id = local.shared_fs
  content_type = "snippets"

  source_raw {
    file_name = "vendor-data.yaml"
    data      = <<-EOF
      #cloud-config
      packages:
        - qemu-guest-agent
      package_update: true
      runcmd:
        - systemctl enable --now qemu-guest-agent
      EOF
  }
}

module "ubuntu_templates" {
  source = "./modules/proxmox/vm-template"

  for_each = {
    focal = {
      year           = 20
      release_date   = "20250624"
      image_checksum = "18f2977d77dfea1b74aee14533bd21c34f789139e949c57023b7364894b7e5e9"
    }
    jammy = {
      year           = 22
      release_date   = "20260826"
      image_checksum = "c0a5af17e6c0f76351fe07e2fffef3011dab1facb8a8ed5701dcf648dabd4f0a"
    }
    # noble = {
    #   year           = 24
    #   release_date   = "20260826"
    #   image_checksum = "d0fe84bb5f80853425fa6be28e2c106f30104c3cfe8611933f2e65c9b63f0e30"
    # }
    resolute = {
      year           = 26
      release_date   = "20260823"
      image_checksum = "8196be9d7958059cb56c6c75c80fdf6cee8a8885bc149ea791d7db1c7ef93035"
    }
  }

  # Image Variables
  image_url                = "https://cloud-images.ubuntu.com/releases/${each.value.year}.04/release-${each.value.release_date}/ubuntu-${each.value.year}.04-server-cloudimg-amd64.img"
  image_checksum           = each.value.image_checksum
  image_checksum_algorithm = "sha256"
  image_overwrite          = false

  # VM Template Variables
  datastore_id     = local.shared_datastore
  vm_id            = tonumber("${each.value.year}04")
  vm_name          = "ubuntu-${each.value.year}-LTS-${each.key}"
  description      = "Ubuntu LTS ${each.value.year}.04 ${each.key} (release date ${each.value.release_date})"
  tags             = ["ubuntu"]
  disk_size        = 32
  qemu_guest_agent = true
  ci_vendor_data   = "${local.shared_fs}:snippets/vendor-data.yaml"

  vcpu            = 4
  memory          = 4096
  memory_floating = 2048

  ci_username = local.ci_username
  ci_password = local.ci_password
  ci_keys     = local.ci_keys
}

module "sle_leap_templates" {
  source = "./modules/proxmox/vm-template"

  for_each = {
    16 = {
      point          = 1
      image_checksum = "79deb563e392fb7ba86ca9e844b90a1a73846ce468d2c44b81d2f583b2ebb76b"
    }
  }

  # Image Variables
  image_url                = "https://download.opensuse.org/distribution/leap/${each.key}.${each.value.point}/appliances/Leap-${each.key}.${each.value.point}-Minimal-VM.x86_64-Cloud-Build2.${each.key}.qcow2"
  image_checksum           = each.value.image_checksum
  image_checksum_algorithm = "sha256"
  image_overwrite          = false
  image_content_type       = "import"

  # VM Template Variables
  datastore_id     = local.shared_datastore
  vm_id            = tonumber(join("", [each.key, format("%02d", each.value.point), "0"]))
  vm_name          = "opensuse-leap-${each.key}"
  description      = "OpenSUSE LEAP ${each.key}.${each.value.point}"
  tags             = ["sle", "leap"]
  disk_size        = 32
  qemu_guest_agent = true
  ci_vendor_data   = "${local.shared_fs}:snippets/vendor-data.yaml"

  vcpu            = 4
  memory          = 4096
  memory_floating = 2048

  ci_username = local.ci_username
  ci_password = local.ci_password
  ci_keys     = local.ci_keys
}

resource "proxmox_virtual_environment_vm" "dc1" {
  name      = "dc1"
  node_name = "pve-3"

  clone {
    vm_id = 2604
  }
}
