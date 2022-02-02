terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Pin the version as recommended in https://www.terraform.io/docs/providers/azurerm/auth/azure_cli.html
      version = "=2.92.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "=2.16.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.2"
    }
  }
  required_version = ">= 1.1.0"
}
