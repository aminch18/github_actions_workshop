provider "azurerm" {
  version = "=2.0.0"
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.agent_client_id
  client_secret   = var.agent_client_secret

  features {}
}

terraform {
  backend "azurerm" {
    storage_account_name = "tfbackend024356e"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
    access_key           = "VmuhIL9+y8I5QBUJ3GePzBlIFi324ObfgiY/67mXO/9slfv4ySX4wpfs7Q1l+zLR1eCHsl+kL4k5CeMkIMqJzg=="
  }
}

resource "azurerm_resource_group" "rg" {
  name     =  var.resource_group_name
  location =  var.location
}

resource "azurerm_container_registry" "acr" {
  name                     = var.container_registry_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Basic"
  admin_enabled            = true
}

resource "azurerm_app_service_plan" "appserviceplan" {
  name                = var.service_plan_name
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  kind = "Linux"
  reserved = true # Mandatory for Linux plans
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_application_insights" "insights" {
    name                = var.insights-name
    location            = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    application_type    = "web"
    retention_in_days   = 730
}

# Create an Azure Web App for Containers in that App Service Plan
resource "azurerm_app_service" "webapp" {
  name                = var.web_app_name
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  app_service_plan_id = "${azurerm_app_service_plan.appserviceplan.id}"
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.acr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = "${azurerm_container_registry.acr.admin_username}"
    DOCKER_REGISTRY_SERVER_PASSWORD = "${azurerm_container_registry.acr.admin_password}"
    APPINSIGHTS_INSTRUMENTATIONKEY =  "${azurerm_application_insights.insights.instrumentation_key}"
  }
  site_config {
    linux_fx_version = "DOCKER|${var.container_registry_name}:${var.tag_name}"
    always_on        = "true"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_app_service_slot" "dev" {
    name                = "${azurerm_app_service.webapp.name}-dev-webapp"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
    app_service_name    = azurerm_app_service.webapp.name
}

resource "azurerm_app_service_slot" "stg" {
    name                = "${azurerm_app_service.webapp.name}-stg-webapp"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
    app_service_name    = azurerm_app_service.webapp.name
}



output "app_service_name" {
  value = "${azurerm_app_service.webapp.name}"
}

output "app_service_default_hostname" {
  value = "https://${azurerm_app_service.webapp.default_site_hostname}"
}