output "id" {
  description = "Instance VM ID"
  value       = proxmox_virtual_environment_vm.vm.id
}

output "ha_resource_id" {
  value = length(proxmox_haresource.ha) > 0 ? proxmox_haresource.ha[0].resource_id : null
}
