locals {
  connect-location = "uksouth"
  connect-rgname   = "connectivity-rg"
}

resource "azurerm_resource_group" "connectivity-rg" {
  provider = azurerm.connectivity-sub
  name     = local.connect-rgname
  location = local.connect-location

  tags = {
    environment = "Connectivity"
  }
}

# Hub virtual network
resource "azurerm_virtual_network" "connectivity-vnet" {
  provider            = azurerm.connectivity-sub
  name                = "hub-vnet"
  location            = local.connect-location
  resource_group_name = local.connect-rgname
  address_space       = ["10.0.0.0/24"]

  tags = {
    environment = "Connectivity"
  }
}

# Subnets
resource "azurerm_subnet" "connectivity-default-subnet" {
  provider             = azurerm.connectivity-sub
  name                 = "default"
  resource_group_name  = local.connect-rgname
  virtual_network_name = azurerm_virtual_network.connectivity-vnet.name
  address_prefixes     = ["10.0.0.0/26"]
}

resource "azurerm_subnet" "firewall-subnet" {
  provider             = azurerm.connectivity-sub
  name                 = "AzureFirewallSubnet"
  resource_group_name  = local.connect-rgname
  virtual_network_name = azurerm_virtual_network.connectivity-vnet.name
  address_prefixes     = ["10.0.0.128/26"]
}

resource "azurerm_subnet" "hub-gateway-subnet" {
  provider             = azurerm.connectivity-sub
  name                 = "GatewaySubnet"
  resource_group_name  = local.connect-rgname
  virtual_network_name = azurerm_virtual_network.connectivity-vnet.name
  address_prefixes     = ["10.0.0.64/27"]
}

# Public IPs
resource "azurerm_public_ip" "gateway-pip" {
  provider            = azurerm.connectivity-sub
  name                = "gateway-public-ip"
  location            = local.connect-location
  resource_group_name = local.connect-rgname
  allocation_method   = "Dynamic"

  tags = {
    environment = "Connectivity"
  }
}

resource "azurerm_public_ip" "firewall-pip" {
  provider            = azurerm.connectivity-sub
  name                = "firewall-pip"
  location            = local.connect-location
  resource_group_name = local.connect-rgname
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "Connectivity"
  }
}

# Virtual Network Gateway
resource "azurerm_virtual_network_gateway" "hub-vpn-gateway" {
  provider            = azurerm.connectivity-sub
  name                = "hub-gateway"
  location            = local.connect-location
  resource_group_name = local.connect-rgname

  type     = "Vpn"
  vpn_type = "RouteBased"

  sku        = var.gw_sku
  generation = "Generation1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gateway-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub-gateway-subnet.id
  }

  depends_on = [azurerm_public_ip.gateway-pip]

  tags = {
    environment = "Connectivity"
  }
}
