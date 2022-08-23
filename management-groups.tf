resource "azurerm_management_group" "mycompany-grp" {
  name         = "StartupCompany"
  display_name = "My Startup Company"
}


# Platform management group
resource "azurerm_management_group" "platform-grp" {
  display_name               = "Platform"
  parent_management_group_id = azurerm_management_group.mycompany-grp.id
}

# Platform child groups:
# Mgmt management group
resource "azurerm_management_group" "connectivity-grp" {
  display_name               = "Connectivity"
  parent_management_group_id = azurerm_management_group.platform-grp.id

  subscription_ids = [
    data.azurerm_subscription.connectivity-sub.subscription_id,
  ]
}

# Connectivity management group
resource "azurerm_management_group" "mgmt-grp" {
  display_name               = "Management Group"
  parent_management_group_id = azurerm_management_group.platform-grp.id

  subscription_ids = [
    data.azurerm_subscription.mgmt-sub.subscription_id,
  ]
}


# Landing Zone management group
resource "azurerm_management_group" "lz-grp" {
  display_name               = "Landing Zones"
  parent_management_group_id = azurerm_management_group.mycompany-grp.id
}

# Landing Zone child groups:
# Corp management group (for an on-premise facing application)
resource "azurerm_management_group" "corp-grp" {
  display_name               = "Corp Landing Zone"
  parent_management_group_id = azurerm_management_group.lz-grp.id

  subscription_ids = [
    data.azurerm_subscription.corp-sub.subscription_id,
  ]
}

# Internet / Online management group (for internet facing application)
resource "azurerm_management_group" "online-grp" {
  display_name               = "Internet Landing Zone"
  parent_management_group_id = azurerm_management_group.lz-grp.id

  subscription_ids = [
    data.azurerm_subscription.online-sub.subscription_id,
  ]
}
