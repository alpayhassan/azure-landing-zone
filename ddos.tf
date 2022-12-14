# Company DDoS protection plan to be associated with virtual networks
# This is a very high cost service

resource "azurerm_resource_group" "mycompany-ddos" {
  provider = azurerm.connectivity-sub
  name     = "ddos-protection-rg"
  location = "uksouth"

  tags = {
    environment = "Connectivity"
  }
}

resource "azurerm_network_ddos_protection_plan" "ddos-pp" {
  provider            = azurerm.connectivity-sub
  name                = "ddos-protection-plan"
  location            = local.connect-location
  resource_group_name = azurerm_resource_group.mycompany-ddos.name

  tags = {
    environment = "Connectivity"
  }
}
