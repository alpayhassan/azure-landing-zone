# This is a very high cost service so I have commented it out to avoid deploying

# Company DDoS protection plan to be associated with virtual networks
/*resource "azurerm_resource_group" "ddos-rg" {
  provider = azurerm.connect-sub
  name     = "ddos-protection-rg"
  location = "uksouth"

  tags = {
    environment = "Connectivity"
  }
}

resource "azurerm_network_ddos_protection_plan" "ddos-pp" {
  provider            = azurerm.connect-sub
  name                = "ddos-protection-plan"
  location            = local.connect-location
  resource_group_name = azurerm_resource_group.ddos-rg.name

  tags = {
    environment = local.connect-tag
  }
}*/
