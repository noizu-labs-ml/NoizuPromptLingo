# ---------------------------------------------------------------------------
# Terraform state bucket bootstrap
# ---------------------------------------------------------------------------
# The init module keeps local state. It still bootstraps the MinIO bucket used by
# downstream S3 backends, but does that from inside Kubernetes so local
# Terraform/OpenTofu plans do not need direct MinIO S3 API access.

variable "tfstate_bucket" {
  description = "Name of the bucket in MinIO that holds downstream Terraform state."
  type        = string
  default     = "tfstate"
}

variable "minio_s3_endpoint" {
  description = "MinIO S3 API endpoint exposed for downstream modules."
  type        = string
  default     = "https://minio.noizu.com"
}

variable "minio_s3_admin_endpoint" {
  description = "Deprecated no-op. Kept only so existing tfvars do not warn; init now creates the tfstate bucket from inside Kubernetes."
  type        = string
  default     = null
  nullable    = true
}

resource "kubernetes_job_v1" "tfstate_bucket" {
  metadata {
    name      = "tfstate-bucket-init"
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
    labels = {
      "app.kubernetes.io/name"      = "minio"
      "app.kubernetes.io/component" = "tfstate-bucket-init"
      "app.kubernetes.io/part-of"   = "platform"
    }
  }

  spec {
    backoff_limit              = 5
    active_deadline_seconds    = 300
    ttl_seconds_after_finished = 600

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"      = "minio"
          "app.kubernetes.io/component" = "tfstate-bucket-init"
        }
      }

      spec {
        restart_policy = "OnFailure"

        container {
          name  = "mc"
          image = "minio/mc:RELEASE.2024-11-17T19-35-25Z"
          command = [
            "/bin/sh",
            "-c",
            <<-EOT
              until mc alias set local "http://${kubernetes_service_v1.minio.metadata[0].name}.${kubernetes_namespace_v1.infra.metadata[0].name}.svc.cluster.local:9000" "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" 2>/dev/null; do
                echo 'Waiting for MinIO...'
                sleep 5
              done
              mc mb --ignore-existing "local/${var.tfstate_bucket}"
              mc version enable "local/${var.tfstate_bucket}"
              echo 'Terraform state bucket ready.'
            EOT
          ]

          env {
            name = "MINIO_ROOT_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.minio_creds.metadata[0].name
                key  = "MINIO_ROOT_USER"
              }
            }
          }

          env {
            name = "MINIO_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.minio_creds.metadata[0].name
                key  = "MINIO_ROOT_PASSWORD"
              }
            }
          }
        }
      }
    }
  }

  wait_for_completion = true

  depends_on = [
    kubernetes_deployment_v1.minio,
    kubernetes_service_v1.minio,
  ]
}

removed {
  from = aws_s3_bucket.tfstate

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_s3_bucket_versioning.tfstate

  lifecycle {
    destroy = false
  }
}
