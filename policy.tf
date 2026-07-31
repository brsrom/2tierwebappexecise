# --- Preventative control: deny creation/update of storage accounts with
#     public blob access enabled, at the network resource group scope.
#     Built-in definition: "Storage account public access should be disallowed"
#
#     This does NOT retroactively affect the existing, intentionally-public
#     mongodb_backups storage account (storage.tf) — Azure Policy deny only
#     intercepts new create/update calls, so that resource just shows as
#     non-compliant rather than being touched.

resource "azurerm_resource_group_policy_assignment" "block_public_blob_access" {
  name                 = "block-public-blob-access"
  resource_group_id    = azurerm_resource_group.network.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/4fa4b6c0-31ca-4c0d-b10d-24b96f62a751"
  display_name         = "Storage account public access should be disallowed"
  description          = "Denies storage accounts with allowBlobPublicAccess enabled in this resource group."

  parameters = jsonencode({
    effect = {
      value = "Deny"
    }
  })
}

# --- Demo: uncomment and `terraform apply` to see the policy above block a
#     new public storage account. Verified 2026-07-31: fails immediately with
#     RequestDisallowedByPolicy, citing this exact policy assignment.
#
# resource "azurerm_storage_account" "policy_test_public" {
#   name                             = "sttestpolicydeny"
#   resource_group_name              = azurerm_resource_group.network.name
#   location                         = azurerm_resource_group.network.location
#   account_tier                     = "Standard"
#   account_replication_type         = "LRS"
#   allow_nested_items_to_be_public  = true
#   public_network_access_enabled    = true
# }
