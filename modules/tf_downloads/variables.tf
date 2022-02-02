variable "azure_subscription_id" {
  type = string
}

variable "azure_tenant_id" {
  type = string
}

variable "azure_location" {
    type = string
    default = "UK South"
}

variable "environment" {
    type = string
}