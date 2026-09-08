ephemeral "sops_file" "secrets" {
  source_file = "secrets.enc.yaml"
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

# Create a custom cloud-init config using BPG provider
resource "proxmox_virtual_environment_file" "cloud_vendor_config" {
  node_name    = "pve-3"
  datastore_id = "cephfs"
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
  vm_id            = tonumber("${each.value.year}04")
  vm_name          = "ubuntu-${each.value.year}-LTS-${each.key}"
  description      = "Ubuntu LTS ${each.value.year}.04 ${each.key} (release date ${each.value.release_date})"
  tags             = ["ubuntu"]
  disk_size        = 32
  qemu_guest_agent = true
  ci_vendor_data   = "cephfs:snippets/vendor-data.yaml"

  vcpu            = 4
  memory          = 4096
  memory_floating = 2048

  ci_username = "ansible"
  ci_password = "ansible"
  ci_keys     = []
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
  vm_id            = tonumber(join("", [each.key, format("%02d", each.value.point), "0"]))
  vm_name          = "opensuse-leap-${each.key}"
  description      = "OpenSUSE LEAP ${each.key}.${each.value.point}"
  tags             = ["sle", "leap"]
  disk_size        = 32
  qemu_guest_agent = true
  ci_vendor_data   = "cephfs:snippets/vendor-data.yaml"

  vcpu            = 4
  memory          = 4096
  memory_floating = 2048

  ci_username = "ansible"
  ci_password = "ansible"
  ci_keys     = []
}

# resource "proxmox_virtual_environment_vm" "my_vm" {
#   name      = "my-vm"
#   node_name = "pve-3"
#
#   vm_id = 200
#   clone {
#     vm_id = 2604
#   }
# }
