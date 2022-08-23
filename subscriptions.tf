# Using data to access existing subscriptions

# Connectivity Subscription
data "azurerm_subscription" "connectivity-sub" {
  provider = azurerm.connectivity-sub
}

output "connectivity_subscription_id" {
  value = data.azurerm_subscription.connectivity-sub.subscription_id
}


# Management Subscription
data "azurerm_subscription" "mgmt-sub" {
  provider = azurerm.mgmt-sub
}

output "management_subscription_id" {
  value = data.azurerm_subscription.mgmt-sub.subscription_id
}


# Corporation Subscription
data "azurerm_subscription" "corp-sub" {
  provider = azurerm.corp-sub
}

output "corporation_subscription_id" {
  value = data.azurerm_subscription.corp-sub.subscription_id
}


# Internet / Online Subscription
data "azurerm_subscription" "online-sub" {
  provider = azurerm.online-sub
}

output "online_subscription_id" {
  value = data.azurerm_subscription.online-sub.subscription_id
}
