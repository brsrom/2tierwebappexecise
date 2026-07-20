output "resource_group_name" {
  description = "Name of the resource group holding the network."
  value       = azurerm_resource_group.network.name
}

output "vnet_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.main.name
}

output "public_subnet_id" {
  description = "ID of the public subnet (VM tier)."
  value       = azurerm_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet (AKS tier)."
  value       = azurerm_subnet.private.id
}

output "legacy_vm_public_ip" {
  description = "Public IP address of the legacy MongoDB VM."
  value       = azurerm_public_ip.legacy_vm.ip_address
}

output "legacy_vm_private_key_path" {
  description = "Local path to the SSH private key for the legacy MongoDB VM."
  value       = local_sensitive_file.legacy_vm_private_key.filename
}

output "legacy_vm_ssh_command" {
  description = "Convenience SSH command for the legacy MongoDB VM."
  value       = "ssh -i ${local_sensitive_file.legacy_vm_private_key.filename} ${var.legacy_vm_admin_username}@${azurerm_public_ip.legacy_vm.ip_address}"
}

output "backup_storage_account_name" {
  description = "Name of the storage account holding MongoDB backups."
  value       = azurerm_storage_account.backups.name
}

output "backup_container_url" {
  description = "Public URL of the MongoDB backups container (anonymous list + read)."
  value       = "${azurerm_storage_account.backups.primary_blob_endpoint}${azurerm_storage_container.mongodb_backups.name}"
}

output "legacy_vm_identity_principal_id" {
  description = "Principal (object) ID of the user-assigned identity attached to the legacy VM, granted Owner on the resource group."
  value       = azurerm_user_assigned_identity.legacy_vm_backup.principal_id
}
