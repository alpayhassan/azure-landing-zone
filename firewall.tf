locals {
  fw-location = "uksouth"
}

# Firewall policy
resource "azurerm_firewall_policy" "firewall-policy" {
  provider            = azurerm.connectivity-sub
  name                = "firewall-policy"
  location            = local.fw-location
  resource_group_name = azurerm_resource_group.connectivity-rg.name
  sku                 = "Premium"

  tags = {
    environment = "Connectivity"
  }
}

# Firewall
resource "azurerm_firewall" "firewall" {
  provider            = azurerm.connectivity-sub
  name                = "firewall"
  location            = local.fw-location
  resource_group_name = azurerm_resource_group.connectivity-rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  firewall_policy_id  = azurerm_firewall_policy.firewall-policy.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall-subnet.id
    public_ip_address_id = azurerm_public_ip.firewall-pip.id
  }

  tags = {
    environment = "Connectivity"
  }
}

# Firewall Policy Rules (enable Private Traffic Routing via the portal)
resource "azurerm_firewall_policy_rule_collection_group" "firewall-policy-rules" {
  provider           = azurerm.connectivity-sub
  name               = "firewall-rules"
  firewall_policy_id = azurerm_firewall_policy.firewall-policy.id
  priority           = 100

  network_rule_collection {
    name     = "network_rule_collection1"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "network_rule_collection1_rule1"
      protocols             = ["TCP", "UDP", "ICMP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}
