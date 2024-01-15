provider "azurerm" {
 features {}
}

resource "azurerm_resource_group" "acr-rg" {
 name     = "acr-rg"
 location = "West Europe"
}

resource "azurerm_container_registry" "acr" {
 name                = "bootcamp-test"
 resource_group_name = azurerm_resource_group.acr-rg.name
 location            = azurerm_resource_group.acr-rg.location
 sku                 = "Basic"
 admin_enabled       = false
}

resource "azurerm_container_registry_repository" "acr" {
 name                 = "myapp"
 container_registry_id = azurerm_container_registry.acr.id
}