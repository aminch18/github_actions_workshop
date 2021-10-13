provider "azurerm" {
  version = "=2.0.0"
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
  name                = "${azurerm_resource_group.rg.name}-plan"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  kind = "Linux"
  reserved = true # Mandatory for Linux plans
  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Create an Azure Web App for Containers in that App Service Plan
resource "azurerm_app_service" "webapp" {
  name                = "${azurerm_resource_group.rg.name}-webapp"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  app_service_plan_id = "${azurerm_app_service_plan.appserviceplan.id}"
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.acr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = "${azurerm_container_registry.acr.admin_username}"
    DOCKER_REGISTRY_SERVER_PASSWORD = "${azurerm_container_registry.acr.admin_password}"
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
    name                = "${azurerm_resource_group.rg.name}-dev-webapp"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
    app_service_name    = azurerm_app_service.webapp.name
}

resource "azurerm_app_service_slot" "stg" {
    name                = "${azurerm_resource_group.rg.name}-stg-webapp"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
    app_service_name    = azurerm_app_service.webapp.name
}

# resource "azurerm_application_insights" "insights" {
#     name                = "${azurerm_resource_group.group.name}-insights"
#     location            = "${azurerm_resource_group.group.location}"
#     resource_group_name = azurerm_resource_group.rg.name
#     application_type    = "web"
#     disable_ip_masking  = true
#     retention_in_days   = 730
# }

output "app_service_name" {
  value = "${azurerm_app_service.webapp.name}"
}

output "app_service_default_hostname" {
  value = "https://${azurerm_app_service.webapp.default_site_hostname}"
}