provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

provider "azuread" {
    tenant_id = var.azure_subscription_id
}

provider "random" {}


terraform {
  backend "local" {
      path = "terraform.tfstate"
  }
}
