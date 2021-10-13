variable "resource_group_name" {
    type        = string
    description = "Azure Resource Group Name."
    default = "rg-github-actions-ws"
}

variable "location" {
    type        = string
    description = "Azure Resource Region Location"
    default = "westeurope"
}

variable "container_registry_name" {
    type        = string
    description = "Azure Container Registry Name"
    default = "acramin"
}

variable "tag_name" {
    type        = string
    description = "Azure Web App Name"
    default     = "latest"
}