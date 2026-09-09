output "id" {
  description = "Template VM ID"
  value       = proxmox_virtual_environment_vm.vm_template.id
}

output "node_name" {
  description = "Node where the template lives"
  value       = proxmox_virtual_environment_vm.vm_template.node_name
}
