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

module "ubuntu26" {
  source = "./modules/proxmox/vm-template"

  # Image Variables
  image_url                = "https://cloud-images.ubuntu.com/releases/26.04/release-20260823/ubuntu-26.04-server-cloudimg-amd64.img" # Required
  image_checksum           = "8196be9d7958059cb56c6c75c80fdf6cee8a8885bc149ea791d7db1c7ef93035"                                       # Required
  image_checksum_algorithm = "sha256"                                                                                                 # Optional
  image_overwrite          = false                                                                                                    # Optional

  # VM Template Variables
  vm_id          = 2604                                             # Required
  vm_name        = "ubuntu-26-resolute-cloudinit"                      # Optional
  description    = "Terraform generated template on ${timestamp()}" # Optional
  tags           = ["ubuntu"]                                        # Optional
  disk_size = 32
  # ci_vendor_data = "local:snippets/vendor-data.yaml"                # Optional
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
