# --- Publicly accessible blob storage for MongoDB backups (exercise) ---

resource "random_string" "backup_storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_account" "backups" {
  name                     = "${var.backup_storage_account_name_prefix}${random_string.backup_storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.network.name
  location                 = azurerm_resource_group.network.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  allow_nested_items_to_be_public = true
  public_network_access_enabled   = true

  tags = local.common_tags
}

resource "azurerm_storage_container" "mongodb_backups" {
  name                  = var.backup_container_name
  storage_account_name  = azurerm_storage_account.backups.name
  container_access_type = "container"
}

# --- Terraform remote state (reuses this storage account; see backend.tf) ---

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.backups.name
  container_access_type = "private"
}

# --- User-assigned identity for the VM, deliberately over-privileged (exercise) ---

resource "azurerm_user_assigned_identity" "legacy_vm_backup" {
  name                = var.legacy_vm_identity_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  tags = local.common_tags
}

resource "azurerm_role_assignment" "legacy_vm_backup_owner" {
  scope                = azurerm_resource_group.network.id
  role_definition_name = "Owner"
  principal_id         = azurerm_user_assigned_identity.legacy_vm_backup.principal_id
}

# --- Installs mongodump + a daily systemd timer that uploads to the public container ---

resource "azurerm_virtual_machine_extension" "mongodb_backup" {
  name                       = "install-mongodb-backup"
  virtual_machine_id         = azurerm_linux_virtual_machine.legacy_vm.id
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.1"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    script = base64encode(templatefile("${path.module}/install-mongodb-backup.sh.tpl", {
      resource_group_name          = azurerm_resource_group.network.name
      storage_account_name         = azurerm_storage_account.backups.name
      container_name               = azurerm_storage_container.mongodb_backups.name
      backup_schedule              = var.backup_schedule
      admin_username               = var.mongodb_admin_username
      admin_password               = random_password.mongodb_admin.result
      legacy_vm_identity_client_id = azurerm_user_assigned_identity.legacy_vm_backup.client_id
    }))
  })

  depends_on = [azurerm_role_assignment.legacy_vm_backup_owner]

  tags = local.common_tags
}
