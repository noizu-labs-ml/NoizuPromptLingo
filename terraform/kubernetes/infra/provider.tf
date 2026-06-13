terraform {
  # use_lockfile (S3-native state locking, no DynamoDB) requires >= 1.10.
  required_version = ">= 1.10"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.2"
    }
    # Applies SealedSecret custom resources (the sealed-secrets controller is
    # installed by the init module). Used instead of kubernetes_manifest, which
    # needs the CRD's schema at plan time.
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.1"
    }
  }

  # ---------------------------------------------------------------------------
  # Remote state in MinIO (S3-compatible) — provisioned by the `init` module.
  # ---------------------------------------------------------------------------
  # Bootstrap order:
  #   1. cd ../init && terraform apply   # deploys MinIO + creates the bucket
  #   2. cd ../infra
  #      export AWS_ACCESS_KEY_ID=<minio_root_user>
  #      export AWS_SECRET_ACCESS_KEY=<minio_root_password>
  #      terraform init                  # migrates/creates state in MinIO
  #
  # Credentials are NEVER stored here — they come from the AWS_* env vars above
  # (or `-backend-config`). Everything else is non-secret and safe to commit.
  backend "s3" {
    bucket = "tfstate"
    key    = "infra/terraform.tfstate"
    region = "us-east-1" # MinIO ignores region; the backend still requires one.

    endpoints = {
      s3 = "https://minio.noizu.com"
    }

    use_path_style              = true # MinIO serves path-style buckets, not vhost-style.
    use_lockfile                = true # S3-native locking (Terraform >= 1.10), no DynamoDB.
    skip_credentials_validation = true # No STS/IAM in MinIO.
    skip_metadata_api_check     = true # No EC2 metadata endpoint.
    skip_region_validation      = true # us-east-1 is a placeholder.
  }
}

provider "kubernetes" {
  config_path    = var.kube_config_path
  config_context = var.kube_context
}

provider "helm" {
  kubernetes = {
    config_path    = var.kube_config_path
    config_context = var.kube_context
  }
}

provider "kubectl" {
  config_path      = var.kube_config_path
  config_context   = var.kube_context
  load_config_file = true
}
