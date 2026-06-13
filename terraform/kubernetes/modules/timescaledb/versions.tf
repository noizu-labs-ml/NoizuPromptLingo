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
  }
}
