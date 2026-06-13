terraform {
  required_version = ">= 1.10"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.1"
    }
  }

  backend "s3" {
    bucket = "tfstate"
    key    = "platform/tobor-locker/terraform.tfstate"
    region = "us-east-1"

    endpoints = {
      s3 = "https://minio.noizu.com"
    }

    use_path_style              = true
    use_lockfile                = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}

provider "kubernetes" {
  config_path    = var.kube_config_path
  config_context = var.kube_context
}

provider "kubectl" {
  config_path      = var.kube_config_path
  config_context   = var.kube_context
  load_config_file = true
}
