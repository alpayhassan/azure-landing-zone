# This subscription contains the centralised logging and monitoring resources

locals {
  mgmt-rgname = "management-resources"
  mgmt-loc = "uksouth"
}

resource "azurerm_resource_group" "management-rg" {
  provider = azurerm.mgmt-sub
  name     = local.mgmt-rgname
  location = local.mgmt-loc
}

# Automation account
resource "azurerm_automation_account" "autom-acc" {
  provider = azurerm.mgmt-sub
  name                = "account1"
  location            = local.mgmt-loc
  resource_group_name = local.mgmt-rgname

  sku_name = "Basic"

  tags = {
    environment = "Management"
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "company-log-analytics-ws" {
  provider = azurerm.mgmt-sub
  name                = "company-la"
  location            = local.mgmt-loc
  resource_group_name = local.mgmt-rgname
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    environment = "Management"
  }
}

# Log Analytics Solution
resource "azurerm_log_analytics_solution" "company-log-analytics-sol" {
  provider = azurerm.mgmt-sub
  solution_name         = "SecurityInsights"
  location            = local.mgmt-loc
  resource_group_name = local.mgmt-rgname
  workspace_resource_id = azurerm_log_analytics_workspace.company-log-analytics-ws.id
  workspace_name        = azurerm_log_analytics_workspace.company-log-analytics-ws.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }

  tags = {
    environment = "Management"
  }
}

# Get started with Azure Sentinel by connecting your data sources
