# Doesn't require connectivity to on-premise
# Can create a web app etc to hold internet-based company applications or websites

locals {
  online-rg                      = "company-website-network-rg"
  online-loc                     = "uksouth"
  online-tag                     = "Online"
  backend_address_pool_name      = "${azurerm_virtual_network.online-application-network.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.online-application-network.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.online-application-network.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.online-application-network.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.online-application-network.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.online-application-network.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.online-application-network.name}-rdrcfg"
}

resource "azurerm_resource_group" "online-network-rg" {
  provider = azurerm.online-sub
  name     = local.online-rg
  location = local.online-loc

  tags = {
    environment = local.online-tag
  }
}

resource "azurerm_network_security_group" "online-network-secgrp" {
  provider            = azurerm.online-sub
  name                = "onlineNetworkSecurityGroup"
  location            = local.online-loc
  resource_group_name = local.online-rg

  tags = {
    environment = local.online-tag
  }
}

resource "azurerm_virtual_network" "online-application-network" {
  provider            = azurerm.online-sub
  name                = "online-application-network"
  location            = local.online-loc
  resource_group_name = local.online-rg
  address_space       = ["10.254.0.0/16"]

  tags = {
    environment = local.online-tag
  }
}

resource "azurerm_subnet" "frontend" {
  provider             = azurerm.online-sub
  name                 = "frontend"
  resource_group_name  = local.online-rg
  virtual_network_name = azurerm_virtual_network.online-application-network.name
  address_prefixes     = ["10.254.0.0/24"]
}

resource "azurerm_subnet" "backend" {
  provider             = azurerm.online-sub
  name                 = "backend"
  resource_group_name  = local.online-rg
  virtual_network_name = azurerm_virtual_network.online-application-network.name
  address_prefixes     = ["10.254.2.0/24"]
}

resource "azurerm_public_ip" "online-application-pip" {
  provider            = azurerm.online-sub
  name                = "online-application-pip"
  resource_group_name = local.online-rg
  location            = local.online-loc
  allocation_method   = "Static"

  tags = {
    environment = local.online-tag
  }
}


# Application Gateway
resource "azurerm_application_gateway" "online-application-gateway" {
  provider            = azurerm.online-sub
  name                = "online-appgateway"
  resource_group_name = local.online-rg
  location            = local.online-loc

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.online-application-pip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  tags = {
    environment = local.online-tag
  }
}


# Resource group for the company online application
resource "azurerm_resource_group" "online-app-rg" {
  provider = azurerm.online-sub
  name     = "application-resources"
  location = local.online-loc

  tags = {
    environment = local.online-tag
  }
}

# App Service Plan
resource "azurerm_service_plan" "online-app-service-plan" {
  provider            = azurerm.online-sub
  name                = "website-sp"
  resource_group_name = azurerm_resource_group.online-app-rg.name
  location            = local.online-loc
  sku_name            = "P1v2"
  os_type             = "Windows"

  tags = {
    environment = local.online-tag
  }
}

# Web App
resource "azurerm_windows_web_app" "company-online-application1" {
  provider            = azurerm.online-sub
  name                = "onlineapp1"
  resource_group_name = azurerm_resource_group.online-app-rg.name
  location            = local.online-loc
  service_plan_id     = azurerm_service_plan.online-app-service-plan.id

  site_config {}

  tags = {
    environment = local.online-tag
  }
}
