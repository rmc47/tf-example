module "tf_downloads_uat" {
  source = "./modules/tf_downloads"

  environment = "uat"
  azure_subscription_id = "68047beb-9ebe-4e07-acc4-906a20e0599b"
  azure_tenant_id = "e30e2b3c-d3bd-482f-bce2-2338a10e1da4"
}

module "tf_downloads_live" {
  source = "./modules/tf_downloads"

  environment = "live"
  azure_subscription_id = "68047beb-9ebe-4e07-acc4-906a20e0599b"
  azure_tenant_id = "e30e2b3c-d3bd-482f-bce2-2338a10e1da4"
}