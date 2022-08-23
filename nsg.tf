# Allowing RDP access to the company on-premise server
resource "azurerm_network_security_group" "corp-nsg" {
  provider            = azurerm.corp-sub
  name                = "Corp-Network-NSG"
  location            = azurerm_resource_group.corp-rg.location
  resource_group_name = azurerm_resource_group.corp-rg.name

  security_rule {
    name                       = "Allow_RDP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "On-Premise"
  }
}

# Associating NSG with Corp default subnet
resource "azurerm_subnet_network_security_group_association" "corp-default-subnet-NSG" {
  provider                  = azurerm.corp-sub
  subnet_id                 = azurerm_subnet.default-corp-subnet.id
  network_security_group_id = azurerm_network_security_group.corp-nsg.id
}
