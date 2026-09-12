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

data "proxmox_virtual_environment_nodes" "all" {}

locals {
  pve_nodes        = toset(data.proxmox_virtual_environment_nodes.all.names)
  local_datastore  = "local_vols"
  template_node    = "pve-3"
  shared_datastore = "cephy"
  shared_fs        = "cephfs"

  # online_nodes = [
  #   for i, name in data.proxmox_virtual_environment_nodes.all.names :
  #   name if data.proxmox_virtual_environment_nodes.all.online[i]
  # ]

  ci_vendor_data = "${proxmox_virtual_environment_file.cloud_vendor_config.datastore_id}:${proxmox_virtual_environment_file.cloud_vendor_config.content_type}/${proxmox_virtual_environment_file.cloud_vendor_config.file_name}"

  user_account = {
    username = data.sops_file.secrets.data["ci.username"]
    password = data.sops_file.secrets.data["ci.password"]
    keys     = yamldecode(data.sops_file.secrets.raw)["ci"]["keys"] # sops provider can't read arrays for some reason - parse it manually
  }
}

# Create a custom cloud-init config using BPG provider
resource "proxmox_virtual_environment_file" "cloud_vendor_config" {
  node_name    = local.template_node
  datastore_id = local.shared_fs
  content_type = "snippets"

  source_raw {
    file_name = "vendor-data.yaml"
    data      = <<-EOF
      #cloud-config
      packages:
        - qemu-guest-agent
      # package_update: false  # Better to create quickly and upgrade later.  Also, specify in UI directly
      runcmd:
        - systemctl enable --now qemu-guest-agent
      EOF
  }
}

locals {
  debian_releases = {
    bookworm = {
      v            = 12
      release_iden = "20260909-2596"
      checksum     = "e95cf7e6fcd8cf9c1bc525cfaa265b9dfc54af5abe07c98186cd533925f228b2b7f9eaec2f650a1923ae9ab56cf09869fe2d17c74037ce8285d955e38365d7ae"
    }
    trixie = {
      v            = 13
      release_iden = "20260831-2587"
      checksum     = "e4f716b1fb48be24085c0907bd1a0a31f03b7bf2adfbd46d9f39595a225dc38741a4b5d79910e61fa1d885ac043e5ea0663fe805f26944e1dc1211a3206022c2"
    }
  }
  ubuntu_lts_releases = {
    focal = {
      year         = 20
      release_date = "20250624"
      checksum     = "18f2977d77dfea1b74aee14533bd21c34f789139e949c57023b7364894b7e5e9"
    }
    jammy = {
      year         = 22
      release_date = "20260826"
      checksum     = "c0a5af17e6c0f76351fe07e2fffef3011dab1facb8a8ed5701dcf648dabd4f0a"
    }
    noble = {
      year         = 24
      release_date = "20260826"
      checksum     = "d0fe84bb5f80853425fa6be28e2c106f30104c3cfe8611933f2e65c9b63f0e30"
    }
    resolute = {
      year         = 26
      release_date = "20260823"
      checksum     = "8196be9d7958059cb56c6c75c80fdf6cee8a8885bc149ea791d7db1c7ef93035"
    }
  }
}


module "microos_img" {
  source = "./modules/proxmox/shared_image"

  node_name    = local.template_node
  datastore_id = local.shared_fs

  # Image Variables
  url = "https://download.opensuse.org/tumbleweed/appliances/openSUSE-MicroOS.x86_64-kvm-and-xen.qcow2"
}

module "ubuntu_img" {
  source = "./modules/proxmox/shared_image"

  node_name    = local.template_node
  datastore_id = local.shared_fs

  for_each = local.ubuntu_lts_releases

  # Image Variables
  url       = "https://cloud-images.ubuntu.com/releases/${each.value.year}.04/release-${each.value.release_date}/ubuntu-${each.value.year}.04-server-cloudimg-amd64.img"
  file_name = "ubuntu-${each.value.year}.04-server-cloudimg-amd64.qcow2"
  # Ubuntu uses the 'wrong' extension and we need to rename it to show in the right place for proxmox
  checksum = each.value.checksum
}

module "ubuntu_template" {
  source   = "./modules/proxmox/vm_from_image"
  template = true
  for_each = local.ubuntu_lts_releases

  node_name    = local.template_node
  datastore_id = local.shared_datastore
  import_from  = module.ubuntu_img[each.key].id

  # VM Template Variables
  vm_id       = tonumber("${each.value.year}04")
  name        = "ubuntu-${each.value.year}-LTS-${each.key}"
  description = "Ubuntu LTS (${each.value.year}.04 ${each.key})"
  tags        = ["ubuntu"]

  vendor_data_file_id = local.ci_vendor_data
  user_account        = local.user_account
}

module "debian_img" {
  source = "./modules/proxmox/shared_image"

  node_name    = local.template_node
  datastore_id = local.shared_fs

  for_each = local.debian_releases

  # Image Variables
  url = "https://cloud.debian.org/images/cloud/${each.key}/${each.value.release_iden}/debian-${each.value.v}-nocloud-amd64-${each.value.release_iden}.qcow2"
  # Ubuntu uses the 'wrong' extension and we need to rename it to show in the right place for proxmox
  checksum           = each.value.checksum
  checksum_algorithm = "sha512"
}

module "debian_template" {
  source   = "./modules/proxmox/vm_from_image"
  template = true
  for_each = local.debian_releases

  node_name    = local.template_node
  datastore_id = local.shared_datastore
  import_from  = module.debian_img[each.key].id

  # VM Template Variables
  vm_id       = tonumber("${each.value.v}00")
  name        = "debian-${each.value.v}-${each.key}"
  description = "Debian ${each.value.v} ${each.key}"
  tags        = ["debian"]

  vendor_data_file_id = local.ci_vendor_data
  user_account        = local.user_account
}

module "sle_leap" {
  source = "./modules/proxmox/shared_template"

  for_each = {
    16 = {
      point    = 1
      checksum = "79deb563e392fb7ba86ca9e844b90a1a73846ce468d2c44b81d2f583b2ebb76b"
    }
  }

  # Image Variables
  node_name = local.template_node
  url       = "https://download.opensuse.org/distribution/leap/${each.key}.${each.value.point}/appliances/Leap-${each.key}.${each.value.point}-Minimal-VM.x86_64-Cloud-Build2.${each.key}.qcow2"
  checksum  = each.value.checksum

  # Template vars
  vm_id               = tonumber(join("", [each.key, format("%02d", each.value.point), "0"]))
  name                = "opensuse-leap-${each.key}"
  description         = "OpenSUSE LEAP ${each.key}.${each.value.point}"
  tags                = ["leap", "sle"]
  vendor_data_file_id = local.ci_vendor_data
  user_account        = local.user_account
}

# resource "proxmox_cloned_vm" "samba-ad-dc" {
#   name      = "dc1"
#   node_name = "pve-3"
#   clone = {
#     source_vm_id     = module.ubuntu_templates["noble"].id
#     source_node_name = module.ubuntu_templates["noble"].node_name
#   }
# }

module "k3s" {
  source    = "./modules/proxmox/vm_from_image"
  for_each  = local.pve_nodes
  node_name = each.key
  name      = join("-", ["k3s", trimprefix(each.key, "pve-")])

  tags = ["k8s", "ubuntu"]

  import_from  = module.ubuntu_img["noble"].id
  datastore_id = local.local_datastore

  cpu_type        = "host"
  cpu_cores       = 4
  memory          = 4096
  memory_floating = 2048

  vendor_data_file_id = local.ci_vendor_data
  user_account        = local.user_account
}


module "komodo" {
  source    = "./modules/proxmox/vm_from_image"
  node_name = local.template_node
  name      = "komodo"

  tags = ["docker", "ubuntu"]

  import_from  = module.ubuntu_img["noble"].id
  datastore_id = local.shared_datastore

  cpu_cores       = 4
  memory          = 4096
  memory_floating = 2048

  vendor_data_file_id = local.ci_vendor_data
  user_account        = local.user_account
  ha                  = true
}


# HA

resource "proxmox_haresource" "komodo" {
  resource_id = "vm:${module.komodo.id}"
  state       = "started"
  comment     = "Managed by Terraform"
}


resource "proxmox_harule" "racks_v3" {
  rule      = "racks_v3"
  type      = "node-affinity"
  comment   = "Run VM's on x86-64v3 and above"
  resources = [proxmox_haresource.komodo.resource_id]

  nodes = {
    pve-2 = null
    pve-3 = null
  }

  strict = true
}
