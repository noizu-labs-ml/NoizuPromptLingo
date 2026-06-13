terraform {
  required_version = ">= 1.10"

  required_providers {
    kubernetes = {
      source  = "registry.terraform.io/hashicorp/kubernetes"
      version = "~> 3.2"
    }
    kubectl = {
      source  = "registry.terraform.io/alekc/kubectl"
      version = "~> 2.1"
    }
    helm = {
      source  = "registry.terraform.io/hashicorp/helm"
      version = "~> 3.2"
    }
  }

  # State in MinIO (provisioned by the root init module). Credentials from AWS_* env.
  backend "s3" {
    bucket = "tfstate"
    key    = "apps/init/terraform.tfstate"
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

provider "helm" {
  kubernetes = {
    config_path    = var.kube_config_path
    config_context = var.kube_context
  }
}
