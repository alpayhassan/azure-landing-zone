# VNet peering between hub and corp landing zone
resource "azurerm_virtual_network_peering" "hub-to-corp-peering" {
  name                      = "peering-hub2corp"
  resource_group_name       = azurerm_resource_group.connectivity-rg.name
  virtual_network_name      = azurerm_virtual_network.connectivity-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.corp-vnet.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
  use_remote_gateways       = false

  depends_on = [azurerm_virtual_network.connectivity-vnet, azurerm_virtual_network_gateway.hub-vpn-gateway, azurerm_virtual_network.corp-vnet]
}

resource "azurerm_virtual_network_peering" "corp-to-hub-peering" {
  name                      = "peering-corp2hub"
  resource_group_name       = azurerm_resource_group.corp-rg.name
  virtual_network_name      = azurerm_virtual_network.corp-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.connectivity-vnet.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = true

  depends_on = [azurerm_virtual_network.connectivity-vnet, azurerm_virtual_network_gateway.hub-vpn-gateway, azurerm_virtual_network.corp-vnet]
}
