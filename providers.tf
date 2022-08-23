terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.16.0"
    }
  }
}

# Default
provider "azurerm" {
  features {}
}

# Connectivity Subscription
provider "azurerm" {
  features {}

  subscription_id = "238cfa4e-8738-4d02-b68c-66eb9f7b09fe"
  alias           = "connectivity-sub"
}

# Management Subscription
provider "azurerm" {
  features {}

  subscription_id = "15f3a1a1-3a55-4bf3-a21c-967b9ac6471b"
  alias           = "mgmt-sub"
}

# Corporation Subscription
provider "azurerm" {
  features {}

  subscription_id = "9e7fd88d-68fc-4c6a-acf5-bc75fb677b74"
  alias           = "corp-sub"
}

# Internet / Online Subscription
provider "azurerm" {
  features {}

  subscription_id = "924f03d1-686a-43a7-b54f-8beddced7e05"
  alias           = "online-sub"
}
