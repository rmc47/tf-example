resource "azurerm_resource_group" "download-example-com-cdn-resourcegroup" {
  name     = "${var.environment}-download-example-com-cdn-resourcegroup"
  location = "northeurope"
}

resource "azurerm_cdn_profile" "download-example" {
  name                = "download-example-cdn"
  location            = azurerm_resource_group.download-example-com-cdn-resourcegroup.location
  resource_group_name = azurerm_resource_group.download-example-com-cdn-resourcegroup.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "download-example" {
  name                = "rg-${var.environment}-download-example"
  profile_name        = azurerm_cdn_profile.download-example.name
  location            = azurerm_resource_group.download-example-com-cdn-resourcegroup.location
  resource_group_name = azurerm_resource_group.download-example-com-cdn-resourcegroup.name

  origin {
    name      = "download-example-com"
    host_name = azurerm_storage_account.example-storage-account.primary_web_host
  }
}