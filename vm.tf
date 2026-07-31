# --- Intentionally outdated Linux + MongoDB host for the exercise ---
# Ubuntu 20.04 LTS: standard support ended April 2025 (1+ year outdated).
# MongoDB 4.4: EOL February 2024 (1+ year outdated), pinned and held via apt.

resource "azurerm_public_ip" "legacy_vm" {
  name                = "pip-${var.legacy_vm_name}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.common_tags
}

resource "azurerm_network_interface" "legacy_vm" {
  name                = "nic-${var.legacy_vm_name}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.legacy_vm.id
  }

  tags = local.common_tags
}

resource "azurerm_linux_virtual_machine" "legacy_vm" {
  name                = var.legacy_vm_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  size                = var.legacy_vm_size
  admin_username      = var.legacy_vm_admin_username

  network_interface_ids = [
    azurerm_network_interface.legacy_vm.id,
  ]

  admin_ssh_key {
    username   = var.legacy_vm_admin_username
    public_key = tls_private_key.legacy_vm.public_key_openssh
  }

  identity {
    # SystemAssigned is added out-of-band by Azure Policy/Guest Configuration
    # remediation (Defender CSPM) shortly after the VM is created; imported
    # here so it stops showing as drift on every plan.
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.legacy_vm_backup.id]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init-legacy-mongo.yaml.tpl", {
    mongodb_version      = var.mongodb_version
    mongodb_full_version = var.mongodb_full_version
  }))

  tags = local.common_tags
}
