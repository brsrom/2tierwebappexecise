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

output "legacy_vm_private_key_pem" {
  description = "SSH private key (PEM) for the legacy MongoDB VM. Retrieve with: terraform output -raw legacy_vm_private_key_pem > key.pem && chmod 600 key.pem"
  value       = tls_private_key.legacy_vm.private_key_openssh
  sensitive   = true
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

output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_get_credentials_command" {
  description = "Command to fetch kubeconfig via az CLI and merge it into your local kubectl config."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.network.name} --name ${azurerm_kubernetes_cluster.main.name}"
}

output "aks_api_server_host" {
  description = "AKS API server endpoint (public)."
  value       = azurerm_kubernetes_cluster.main.kube_config[0].host
  sensitive   = true
}

output "acr_login_server" {
  description = "Login server for the container registry (docker login / docker push target)."
  value       = azurerm_container_registry.main.login_server
}

output "acr_name" {
  description = "Name of the container registry."
  value       = azurerm_container_registry.main.name
}

output "mongodb_admin_credentials" {
  description = "MongoDB admin username/password/connect command. Retrieve with: terraform output -raw mongodb_admin_credentials"
  value       = <<-EOT
    username: ${var.mongodb_admin_username}
    password: ${random_password.mongodb_admin.result}
    connect:  mongo -u ${var.mongodb_admin_username} -p '${random_password.mongodb_admin.result}' --authenticationDatabase admin
  EOT
  sensitive   = true
}
