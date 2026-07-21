# --- AKS cluster in the private subnet, public API server for kubectl access ---

resource "azurerm_user_assigned_identity" "aks" {
  name                = var.aks_identity_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  tags = local.common_tags
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = azurerm_subnet.private.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  dns_prefix          = var.aks_dns_prefix
  oidc_issuer_enabled = true

  default_node_pool {
    name           = "default"
    node_count     = var.aks_node_count
    vm_size        = var.aks_node_vm_size
    vnet_subnet_id = azurerm_subnet.private.id

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
    pod_cidr          = "10.244.0.0/16"
    service_cidr      = "172.16.0.0/16"
    dns_service_ip    = "172.16.0.10"
  }

  depends_on = [azurerm_role_assignment.aks_network_contributor]

  tags = local.common_tags
}

resource "local_sensitive_file" "aks_kubeconfig" {
  content         = azurerm_kubernetes_cluster.main.kube_config_raw
  filename        = "${path.module}/.ssh/kubeconfig-${var.aks_cluster_name}"
  file_permission = "0600"
}
