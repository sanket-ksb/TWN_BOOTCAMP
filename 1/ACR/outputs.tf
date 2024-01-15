output "resource_group_name" {
 value = azurerm_resource_group.acr-rg.name
}

output "container_registry_name" {
 value = azurerm_container_registry.acr.name
}

output "repository_name" {
 value = azurerm_container_registry_repository.acr.name
}