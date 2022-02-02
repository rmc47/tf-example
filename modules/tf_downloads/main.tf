resource "azurerm_resource_group" "download-example-com-resourcegroup" {
  name     = "${var.environment}-download-example-com-resourcegroup"
  location = var.azure_location
}

resource "azurerm_storage_account" "example-storage-account" {
  name                     = "${var.environment}examplestorage"
  resource_group_name      = azurerm_resource_group.download-example-com-resourcegroup.name
  location                 = azurerm_resource_group.download-example-com-resourcegroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Cool" # 😎
  allow_blob_public_access = true
}

resource "azurerm_storage_container" "download-example-com-container" {
  name                  = "${var.environment}-download-example-com-container"
  storage_account_name  = azurerm_storage_account.example-storage-account.name
  container_access_type = "container"
}

resource "azuread_application" "product-release-example-app" {
  display_name = "${var.environment}-product-release-example"
}

resource "azuread_service_principal" "product-release-example-principal" {
  application_id = azuread_application.product-release-example-app.application_id
}

resource "azuread_service_principal_password" "product-release-example-principal-password" {
  service_principal_id = azuread_service_principal.product-release-example-principal.object_id
}

resource "azurerm_role_assignment" "product-release-example-access" {
    scope = azurerm_storage_container.download-example-com-container.resource_manager_id
    role_definition_name = "Storage Blob Data Contributor"
    principal_id = azuread_service_principal.product-release-example-principal.object_id
}


output "principal-password" {
  value = azuread_service_principal_password.product-release-example-principal-password.value
}

output "principal-key-id" {
  value = azuread_service_principal_password.product-release-example-principal-password.key_id
}
