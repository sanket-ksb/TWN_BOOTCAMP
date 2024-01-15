variable "resource_group_name" {
 description = "The name of the resource group."
 type        = string
 default     = "acr-rg"
}

variable "container_registry_name" {
 description = "The name of the Azure Container Registry."
 type        = string
 default     = "bootcamp-test"
}

variable "repository_name" {
 description = "The name of the Docker repository."
 type        = string
 default     = "myapp"
}