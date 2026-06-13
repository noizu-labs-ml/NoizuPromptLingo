terraform {
  backend "s3" {
    bucket = "tf-state"
    key    = "zero-trust/terraform.tfstate"
    region = "us-east-1"

    endpoints = {
      s3 = "https://minio.noizu.com"
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}
