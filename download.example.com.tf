module "tf_downloads_uat" {
  source = "./modules/tf_downloads"

  bucket_name = "tf-downloads-uat"
  dns_name = "download.uat.example.com"
  iam_user = "ProductRelease-uat"

  bucket_lifecycle_expiration_rules = {
    "beta/" = 10
    "updates/" = 20
    "installers/" = 30
  }
}

module "tf_downloads_live" {
  source = "./modules/tf_downloads"

  bucket_name = "tf-downloads-live"
  dns_name = "download.example.com"
  iam_user = "ProductRelease"

  bucket_lifecycle_expiration_rules = {}
}

output "tf_downloads_uat_secret_access_key" {
  value = module.tf_downloads_uat.secret_access_key
  sensitive = true
}

output "tf_downloads_live_secret_access_key" {
  value = module.tf_downloads_live.secret_access_key
  sensitive = true
}
