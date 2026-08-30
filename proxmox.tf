provider "proxmox" {
  endpoint  = data.sops_file.secrets.data["proxmox.endpoint"]
  api_token = join("=", [data.sops_file.secrets.data["proxmox.token_id"], data.sops_file.secrets.data["proxmox.secret"]])
  # api_token = "blog_example@pam!terraform=your-api-token-secret"
  insecure  = false # set to false if using a valid TLS certificate
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

module "ubuntu26" {
  source = "./modules/proxmox/vm-template"

  # Image Variables
  image_url                = "https://cloud-images.ubuntu.com/releases/26.04/release-20260823/ubuntu-26.04-server-cloudimg-amd64.img"
  image_checksum           = "8196be9d7958059cb56c6c75c80fdf6cee8a8885bc149ea791d7db1c7ef93035"
  image_checksum_algorithm = "sha256"
  image_overwrite          = false

  # VM Template Variables
  vm_id          = 2604
  vm_name        = "ubuntu-26-LTS-resolute"
  description    = "Terraform generated template"
  tags           = ["ubuntu"]
  disk_size = 32
  qemu_guest_agent = true
  ci_vendor_data = "cephfs:snippets/vendor-data.yaml"

  vcpu = 4
  memory = 4096
  memory_floating = 2048
}

# resource "proxmox_virtual_environment_vm" "my_vm" {
#   name      = "my-vm"
#   node_name = "pve-3"
#
#   clone {
#     vm_id = 2404 # replace with the numeric ID of your template VM in Proxmox
#   }
#   agent {
#     # enabled = true
#     enabled = false
#     # timeout = "20s" # <-- Cuts off the indefinite polling hang on initial provision
#   }
# }
