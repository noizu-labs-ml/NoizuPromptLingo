terraform {
  required_version = ">= 1.4.0"

  required_providers {
    namecheap = {
      source  = "namecheap/namecheap"
      version = "~> 2.2"
    }
  }

  backend "s3" {
    bucket = "tf-state"
    key    = "namecheap/terraform.tfstate"
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

provider "namecheap" {
  alias     = "noizu"
  user_name = var.noizu_namecheap_user_name
  api_user  = var.noizu_namecheap_api_user
  api_key   = var.noizu_namecheap_api_key
}

provider "namecheap" {
  alias     = "trl"
  user_name = var.trl_namecheap_user_name
  api_user  = var.trl_namecheap_api_user
  api_key   = var.trl_namecheap_api_key
}
