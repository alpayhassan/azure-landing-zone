locals {
  location    = "uksouth"
  corp-tag    = "Corp"
  corp-rgname = "on-premise-application-rg"
}

resource "azurerm_resource_group" "corp-rg" {
  provider = azurerm.corp-sub
  name     = local.corp-rgname
  location = local.location

  tags = {
    environment = local.corp-tag
  }
}

# A virtual network created for a company's on-premise facing application
resource "azurerm_virtual_network" "corp-vnet" {
  provider            = azurerm.corp-sub
  name                = "corp-network"
  location            = local.location
  resource_group_name = local.corp-rgname
  address_space       = ["10.1.0.0/24"]

  tags = {
    environment = local.corp-tag
  }
}

resource "azurerm_subnet" "default-corp-subnet" {
  provider             = azurerm.corp-sub
  name                 = "default"
  resource_group_name  = local.corp-rgname
  virtual_network_name = azurerm_virtual_network.corp-vnet.name
  address_prefixes     = ["10.1.0.0/25"]
}
