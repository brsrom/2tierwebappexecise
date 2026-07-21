variable "location" {
  description = "Azure region to deploy resources into."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the resource group that will hold the network resources."
  type        = string
  default     = "rg-2tier-wizexercise"
}

variable "environment" {
  description = "Environment tag applied to all resources (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
  default     = "vnet-2tier"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "public_subnet_name" {
  description = "Name of the public subnet used by the VM."
  type        = string
  default     = "snet-public-vm"
}

variable "public_subnet_address_prefix" {
  description = "Address prefix for the public subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_name" {
  description = "Name of the private subnet used by the Kubernetes cluster."
  type        = string
  default     = "snet-private-aks"
}

variable "private_subnet_address_prefix" {
  description = "Address prefix for the private (AKS) subnet."
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "allowed_ssh_source_address_prefix" {
  description = "Source address prefix (CIDR or IP) allowed to reach the VM over SSH/RDP. Restrict this to your own IP in production."
  type        = string
  default     = "*"
}

variable "legacy_vm_name" {
  description = "Name of the intentionally outdated VM (public subnet) hosting MongoDB for the exercise."
  type        = string
  default     = "vm-legacy-mongo"
}

variable "legacy_vm_size" {
  description = "VM size for the legacy MongoDB host."
  type        = string
  default     = "Standard_B2s"
}

variable "legacy_vm_admin_username" {
  description = "Admin username for the legacy MongoDB VM."
  type        = string
  default     = "azureadmin"
}

variable "mongodb_version" {
  description = "MongoDB minor release line to install (must be EOL / 1+ year outdated for the exercise)."
  type        = string
  default     = "4.4"
}

variable "mongodb_full_version" {
  description = "Exact MongoDB patch version to pin via apt (last patch of the mongodb_version line)."
  type        = string
  default     = "4.4.29"
}

variable "backup_storage_account_name_prefix" {
  description = "Prefix for the globally-unique storage account name that stores MongoDB backups (a random suffix is appended)."
  type        = string
  default     = "st2tiermongobkp"
}

variable "backup_container_name" {
  description = "Blob container name for MongoDB backups."
  type        = string
  default     = "mongodb-backups"
}

variable "backup_schedule" {
  description = "systemd OnCalendar expression for the daily MongoDB backup job."
  type        = string
  default     = "*-*-* 02:00:00"
}

variable "legacy_vm_identity_name" {
  description = "Name of the user-assigned managed identity attached to the legacy MongoDB VM."
  type        = string
  default     = "id-vm-legacy-mongo-backup"
}

variable "mongodb_admin_username" {
  description = "MongoDB admin username to create with root privileges once authentication is enabled."
  type        = string
  default     = "admin"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster deployed into the private subnet."
  type        = string
  default     = "aks-2tier-wizexercise"
}

variable "aks_dns_prefix" {
  description = "DNS prefix for the AKS cluster's public API server FQDN."
  type        = string
  default     = "aks-2tier-wizexercise"
}

variable "aks_node_count" {
  description = "Number of nodes in the AKS default node pool (single node, sufficient for testing)."
  type        = number
  default     = 1
}

variable "aks_node_vm_size" {
  description = "VM size for AKS nodes."
  type        = string
  default     = "Standard_B2s"
}

variable "aks_identity_name" {
  description = "Name of the user-assigned managed identity used by the AKS control plane to manage the private subnet."
  type        = string
  default     = "id-aks-2tier-wizexercise"
}
