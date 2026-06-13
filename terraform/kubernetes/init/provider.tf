terraform {
  required_version = ">= 1.5"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.2"
    }
    # Generates the shared Valkey ACL user passwords (source of truth, consumed
    # by the infra + infra-services modules via remote state). See valkey-creds.tf.
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# Cluster connection. Override per target (e.g. docker-desktop) via terraform.tfvars
# or TF_VAR_kube_config_path / TF_VAR_kube_config_context. Provider config is
# resolved at plan time, so these must be variables/locals — not computed values.
variable "kube_config_path" {
  description = "Path to the kubeconfig file."
  type        = string
}

variable "kube_config_context" {
  description = "kubeconfig context to target."
  type        = string
}

provider "kubernetes" {
  config_path    = var.kube_config_path
  config_context = var.kube_config_context
}

provider "helm" {
  kubernetes = {
    config_path    = var.kube_config_path
    config_context = var.kube_config_context
  }
}
