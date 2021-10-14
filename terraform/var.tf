variable "subscription_id" {
  description = "The azure account subscription id"
  type        = string
  default = "35b4bd8a-6448-4d3d-9899-f689de54063c"
}

variable "client_id" {
  description = "The azure account client application id"
  type        = string
  default = "6274185b-c128-4840-a1dc-4beb278411a6"
}

variable "client_secret" {
  description = "The azure account client secret"
  type        = string
  default = "3HKffZce8Vwa2QjdCez_jPacyXyLH.jHH0"
}

variable "tenant_id" {
  description = "The azure account tenant guid"
  type        = string
  default = "c63f639b-2dcc-40ee-a928-17802ba223ed"
}

variable "resource_group_name" {
    type        = string
    description = "Azure Resource Group Name."
    default = "rg-github-actions-wshop"
}

variable "web_app_name" {
    type        = string
    description = "Azure Resource Group Name."
    default = "todoapi-webapp"
}
variable "service_plan_name" {
    type        = string
    description = "Azure Resource Group Name."
    default = "todoapi-service-plan"
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