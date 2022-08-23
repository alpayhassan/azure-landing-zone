# Routing from Corp Landing Zone to the office network (on-premise)
resource "azurerm_route_table" "route-table-corp-to-office" {
  provider = azurerm.corp-sub
  name                          = "corp2office"
  location                      = azurerm_resource_group.corp-rg.location
  resource_group_name           = azurerm_resource_group.corp-rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "to-office"
    address_prefix = "185.169.225.59"
    next_hop_type  = "VirtualNetworkGateway"
  }

  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VnetLocal"
  }

  tags = {
    environment = "Corp"
  }
}
