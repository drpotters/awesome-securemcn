########################### Providers ##########################

terraform {
  required_version = "~> 1.0"

  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = ">= 0.11.26"
    }
    azurerm = ">= 3.73.0"
  }
}

provider "azurerm" {
  features {}
}

provider "volterra" {
  timeout = "90s"
}

############################ Zones ############################

resource "random_shuffle" "zones" {
  input = var.azureZones
  keepers = {
    azureLocation = var.azureLocation
  }
}

############################ Client IP ############################

# Retrieve client public IP
data "http" "ipinfo" {
  url = "https://ifconfig.me/ip"
}

############################ Locals ############################

locals {
  clientIp = format("%s/32", data.http.ipinfo.response_body)
}

############################ Resource Groups ############################

# Create Resource Groups
resource "azurerm_resource_group" "rg" {
  name     = format("%s-%s-tfc", var.projectPrefix, local.build_suffix)
  location = var.azureLocation

  tags = {
    Owner = var.resourceOwner
  }
}

############################ VNets ############################

# Create VNets
module "network" {
  source              = "Azure/vnet/azurerm"
  version             = ">= 4.0.0"
  use_for_each        = false
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name           = format("%s-vnet-%s", var.projectPrefix, local.build_suffix)
  vnet_location       = var.azureLocation
  address_space       = [var.vnetCidr]
  subnet_prefixes     = var.subnetPrefixes
  subnet_names        = var.subnetNames

  tags = {
    Name  = format("%s-vnet-%s", var.projectPrefix, local.build_suffix)
    Owner = var.resourceOwner
  }

  subnet_delegation = {
    workload = {
      "aks-delegation" = {
          service_actions = [ "Microsoft.Network/virtualNetworks/subnets/join/action" ]
          service_name    = "Microsoft.ContainerService/managedClusters"
      }
    }
  }
  
  depends_on = [azurerm_resource_group.rg]
}


### Outbound (Northbound) NAT ###
/* resource "azurerm_public_ip" "natgw-aks" {
  name                = "aks-natgw-PIP"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
} */
resource "azurerm_public_ip" "firewall-pip" {
  name                = "aks-firewall-PIP"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
/* resource "azurerm_nat_gateway" "natgw-aks" {
  name = "natgw-aks"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_nat_gateway_public_ip_association" "natgw-aks" {
  nat_gateway_id       = azurerm_nat_gateway.natgw-aks.id
  public_ip_address_id = azurerm_public_ip.natgw-aks.id
}
resource "azurerm_subnet_nat_gateway_association" "natgw-aks" {
  subnet_id      = lookup(module.network.vnet_subnets_name_id, "public")
  nat_gateway_id = azurerm_nat_gateway.natgw-aks.id
} */
resource "azurerm_firewall" "firewall" {
  name                = "aks-firewall"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  ip_configuration {
    name                 = "configuration"
    subnet_id            = lookup(module.network.vnet_subnets_name_id, "AzureFirewallSubnet")
    public_ip_address_id = azurerm_public_ip.firewall-pip.id
  }
}
resource "azurerm_firewall_network_rule_collection" "aks-firewall-rules" {
  name                = "aks-firewall-rules"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 101
  action              = "Allow"

  rule {
    name = "all"
    source_addresses = ["*"]
    destination_addresses = ["*"]
    destination_ports = ["*"]
    protocols = ["Any"]
  }
}

### UDR Route Table for the SLO subnet ###
resource "azurerm_route_table" "mcn-networks" {
  name = "rt-mcn-networks"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name = "to_MCN-aws"
    address_prefix = "10.1.0.0/16"
    next_hop_in_ip_address = local.xc_site_slo_ip
    next_hop_type = "VirtualAppliance"
  }
  route {
    name = "default"
    address_prefix = "0.0.0.0/0"
    // next_hop_type = "Internet"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
    next_hop_type = "VirtualAppliance"
  }

  depends_on = [ volterra_tf_params_action.apply ]
}

resource "azurerm_subnet_route_table_association" "public" {
  subnet_id = lookup(module.network.vnet_subnets_name_id, "public")
  route_table_id = azurerm_route_table.mcn-networks.id
}

############################ Security Groups - Web Servers ############################

# Webserver Security Group
resource "azurerm_network_security_group" "webserver" {
  name                = format("%s-nsg-webservers-%s", var.projectPrefix, local.build_suffix)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = local.commonClientIP
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_HTTP"
    description                = "Allow HTTP access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = local.commonClientIP
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_8080"
    description                = "Allow HTTP access"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = var.vnetCidr
    destination_address_prefix = "*"
  }

  tags = {
    Owner = var.resourceOwner
  }

  depends_on = [azurerm_resource_group.rg]
}
