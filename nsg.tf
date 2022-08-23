# Corp Landing Zone NSG
resource "azurerm_network_security_group" "corp-nsg" {
  provider            = azurerm.corp-sub
  name                = "corp-NetworkSecurityGroup"
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
    environment = "Corp"
  }
}

# Associating NSG with Corp default subnet
resource "azurerm_subnet_network_security_group_association" "corp-default-subnet-nsg" {
  provider                  = azurerm.corp-sub
  subnet_id                 = azurerm_subnet.default-corp-subnet.id
  network_security_group_id = azurerm_network_security_group.corp-nsg.id
}


# Online Landing Zone NSG
resource "azurerm_network_security_group" "online-network-secgrp" {
  provider            = azurerm.online-sub
  name                = "online-NetworkSecurityGroup"
  location            = azurerm_resource_group.online-network-rg.location
  resource_group_name = azurerm_resource_group.online-network-rg.name

  tags = {
    environment = "Online"
  }
}

# Associating NSG with Online network subnets
resource "azurerm_subnet_network_security_group_association" "online-frontend-subnet-nsg" {
  provider                  = azurerm.online-sub
  subnet_id                 = azurerm_subnet.frontend.id
  network_security_group_id = azurerm_network_security_group.online-network-secgrp.id
}

resource "azurerm_subnet_network_security_group_association" "online-backend-subnet-nsg" {
  provider                  = azurerm.online-sub
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.online-network-secgrp.id
}
