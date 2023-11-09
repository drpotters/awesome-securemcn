locals {
  resourceGroup = data.tfe_outputs.azure.values.resourceGroup
  buildSuffix = data.tfe_outputs.root.values.buildSuffix
  vnetName = data.tfe_outputs.azure.values.vnetName
}

# Retrieves subnet info
data "azurerm_subnet" "nodes" {
  name                 = "public"
  virtual_network_name = local.vnetName
  resource_group_name  = local.resourceGroup
}
data "azurerm_subnet" "pods" {
  name                 = "workload"
  virtual_network_name = local.vnetName
  resource_group_name  = local.resourceGroup
}
data "azurerm_resource_group" "rg" {
  name = local.resourceGroup
}

resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = format("%s-%s-aks-cluster", var.projectPrefix, local.buildSuffix)
  location            = var.azureLocation
  resource_group_name = local.resourceGroup
  dns_prefix          = "xc-aks"

  network_profile {
    network_plugin = "azure"
    outbound_type = "userDefinedRouting"
  }
  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2_v2"
    vnet_subnet_id = data.azurerm_subnet.nodes.id
    // pod_subnet_id = data.azurerm_subnet.pods.id
    temporary_name_for_rotation = local.buildSuffix
  }

  identity {
    type = "SystemAssigned"
    /* type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id] */
  }

  tags = {
    Environment = "Production"
  }
}

### IAM For AKS to create an LB in subnets ###
data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "current" {
}

/* resource "azurerm_user_assigned_identity" "aks" {
  location            = var.azureLocation
  name                = "${var.projectPrefix}-${local.buildSuffix}-tf-uai"
  resource_group_name = local.resourceGroup
} */

/* data "azurerm_user_assigned_identity" "aks_identity" {
  resource_group_name = local.resourceGroup
  // location            = var.azureLocation

  name = "f5xc-tfc-dpotter"
} */

/* resource "azurerm_role_definition" "aks-role-vnet" {
  name               = "aks-lb-role"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["Microsoft.Resources/subscriptions/resourceGroups/read"]
    not_actions = []
  }

  assignable_scopes = [
    format("%s/resourcegroups/%s", data.azurerm_subscription.primary.id, local.resourceGroup)
  ]
} */

resource "azurerm_role_assignment" "system-managed-kubelet" {
  // scope = data.azurerm_subscription.primary.id
  scope = data.azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
  // principal_id = azurerm_kubernetes_cluster.aks-cluster.identity[0].principal_id
  principal_id = azurerm_kubernetes_cluster.aks-cluster.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "system-managed-aks-cluster" {
  scope = data.azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
  // principal_id = azurerm_kubernetes_cluster.aks-cluster.identity[0].principal_id
  principal_id = azurerm_kubernetes_cluster.aks-cluster.identity[0].principal_id
}