provider "proxmox" {
  endpoint  = data.sops_file.secrets.data["proxmox.endpoint"]
  api_token = join("=", [data.sops_file.secrets.data["proxmox.token_id"], data.sops_file.secrets.data["proxmox.secret"]])
  # api_token = "blog_example@pam!terraform=your-api-token-secret"
  insecure  = false # set to false if using a valid TLS certificate
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
