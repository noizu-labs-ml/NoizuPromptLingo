# ---------------------------------------------------------------------------
# MinIO — S3-compatible object storage (infra namespace).
# ---------------------------------------------------------------------------
# Translated to Terraform from the platform Helm chart
# (noizu-infra/kubernetes/helm/platform/minio). Differences from that chart:
#   - Namespace is `infra` (not platform-ns).
#   - Root credentials come from a Terraform-managed Secret sourced from
#     TF_VAR_minio_root_user / TF_VAR_minio_root_password (the chart used the
#     Infisical operator; this bootstrap module has no Infisical).
#   - TLS is a self-signed cert generated here (replace with the real
#     Cloudflare cert in production — the ingress reference is unchanged).
#
# Exposes:
#   minio.noizu.com          → S3 API     (port 9000)
#   minio-console.noizu.com  → web console (port 9001)

locals {
  minio_image           = "quay.io/minio/minio:RELEASE.2025-09-07T16-13-09Z"
  minio_api_port        = 9000
  minio_console_port    = 9001
  minio_host            = "minio.noizu.com"
  minio_console_host    = "minio-console.noizu.com"
  minio_tls_secret_name = "minio-noizu-com-tls"
  minio_creds_secret    = "minio-secrets"
}

variable "minio_root_user" {
  description = "MinIO root (admin) username."
  type        = string
  default     = "minioadmin"
}

variable "minio_root_password" {
  description = "MinIO root (admin) password. Set via TF_VAR_minio_root_password; do not commit a real value."
  type        = string
  sensitive   = true
}

# Pin MinIO to the base colo server (noizu-server). Its Longhorn volume data
# lives on the base, so the pod must not reschedule onto a VM member (k8s-mvm-*).
# No nodes are tainted, so a nodeSelector alone is sufficient. To make the pin
# portable, label the base node (e.g. `kubectl label node noizu-server
# noizu.com/role=base`) and set this to { "noizu.com/role" = "base" }.
variable "minio_node_selector" {
  description = "nodeSelector used to pin the MinIO pod to the base node."
  type        = map(string)
  default     = { "kubernetes.io/hostname" = "noizu-server" }
}

# *.noizu.com wildcard Cloudflare cert. This is the root init of the server,
# which runs BEFORE the cert-sync mechanism (the cluster-wide
# `cloudflare-tls-synced` secret) exists — so the cert/key are supplied here as
# tfvars rather than referenced from an in-cluster secret. Provide via
# TF_VAR_minio_tls_cert / TF_VAR_minio_tls_key (e.g. from the PEM files); do not
# commit the key.
variable "minio_tls_cert" {
  description = "PEM-encoded *.noizu.com wildcard certificate (full chain)."
  type        = string
}

variable "minio_tls_key" {
  description = "PEM-encoded private key for the *.noizu.com wildcard certificate."
  type        = string
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Root credentials Secret (Terraform-managed)
# ---------------------------------------------------------------------------
resource "kubernetes_secret_v1" "minio_creds" {
  metadata {
    name      = local.minio_creds_secret
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
    labels = {
      "app.kubernetes.io/name"    = "minio"
      "app.kubernetes.io/part-of" = "platform"
    }
  }
  type = "Opaque"
  data = {
    MINIO_ROOT_USER     = var.minio_root_user
    MINIO_ROOT_PASSWORD = var.minio_root_password
  }
}

# ---------------------------------------------------------------------------
# Data volume (Longhorn)
# ---------------------------------------------------------------------------
resource "kubernetes_persistent_volume_claim_v1" "minio" {
  metadata {
    name      = "minio-data-pvc"
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
    labels = {
      "app.kubernetes.io/name"    = "minio"
      "app.kubernetes.io/part-of" = "platform"
    }
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "longhorn"
    resources {
      requests = {
        storage = "100Gi"
      }
    }
  }
  # longhorn binds immediately; don't block apply waiting for first consumer.
  wait_until_bound = false

  depends_on = [helm_release.longhorn]
}

# ---------------------------------------------------------------------------
# Deployment
# ---------------------------------------------------------------------------
resource "kubernetes_deployment_v1" "minio" {
  metadata {
    name      = "minio"
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
    labels = {
      "app.kubernetes.io/name"    = "minio"
      "app.kubernetes.io/part-of" = "platform"
    }
  }
  spec {
    replicas = 1
    strategy {
      type = "Recreate" # single RWO volume
    }
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "minio"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"    = "minio"
          "app.kubernetes.io/part-of" = "platform"
        }
      }
      spec {
        # Pin to the base colo server — keep MinIO co-located with its data.
        node_selector = var.minio_node_selector

        container {
          name  = "minio"
          image = local.minio_image
          args = [
            "server",
            "/data",
            "--console-address",
            ":${local.minio_console_port}",
          ]

          port {
            container_port = local.minio_api_port
            name           = "api"
          }
          port {
            container_port = local.minio_console_port
            name           = "console"
          }

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

          readiness_probe {
            http_get {
              path = "/minio/health/ready"
              port = local.minio_api_port
            }
            initial_delay_seconds = 10
            period_seconds        = 15
          }
          liveness_probe {
            http_get {
              path = "/minio/health/live"
              port = local.minio_api_port
            }
            initial_delay_seconds = 20
            period_seconds        = 30
          }

          # MinIO is pinned to the base node; give it a floor and a memory cap
          # so it can't starve co-located pods. No CPU limit (avoid throttling
          # S3 throughput); memory limit guards against the cache growing
          # unbounded under load.
          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
            limits = {
              memory = "2Gi"
            }
          }

          volume_mount {
            name       = "minio-data"
            mount_path = "/data"
          }
        }

        volume {
          name = "minio-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.minio.metadata[0].name
          }
        }
      }
    }
  }

  timeouts {
    create = "10m"
    update = "10m"
  }
}

# ---------------------------------------------------------------------------
# Service
# ---------------------------------------------------------------------------
resource "kubernetes_service_v1" "minio" {
  metadata {
    name      = "minio-service"
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "minio"
    }
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app.kubernetes.io/name" = "minio"
    }
    port {
      port        = 9000
      target_port = local.minio_api_port
      name        = "api"
    }
    port {
      port        = 9001
      target_port = local.minio_console_port
      name        = "console"
    }
  }
}

# ---------------------------------------------------------------------------
# TLS — *.noizu.com wildcard Cloudflare cert (supplied via tfvars).
# ---------------------------------------------------------------------------
# minio.noizu.com and minio-console.noizu.com are both covered by the wildcard,
# matching how the other noizu.com services are served (cloudflare-tls-synced).
# Here at root-init the synced secret doesn't exist yet, so we materialise the
# wildcard cert into the infra namespace from the tfvar inputs.
resource "kubernetes_secret_v1" "minio_tls" {
  metadata {
    name      = local.minio_tls_secret_name
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.crt" = var.minio_tls_cert
    "tls.key" = var.minio_tls_key
  }
}

# ---------------------------------------------------------------------------
# Ingress — API (minio.noizu.com) and console (minio-console.noizu.com)
# ---------------------------------------------------------------------------
locals {
  # Annotations carried over from the platform chart: large uploads + long
  # timeouts for S3 traffic. The old setup also forced Accept-Encoding: identity
  # on upstream requests via a configuration-snippet; that is now done globally on
  # the controller (controller.proxySetHeaders in controllers.tf) so we don't need
  # a per-ingress snippet, which the controller rejects by default.
  minio_ingress_annotations = {
    "nginx.ingress.kubernetes.io/proxy-body-size"    = "0"
    "nginx.ingress.kubernetes.io/proxy-read-timeout" = "600"
    "nginx.ingress.kubernetes.io/proxy-send-timeout" = "600"
    "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
  }
}

resource "kubernetes_ingress_v1" "minio_api" {
  metadata {
    name        = "minio-api-ingress"
    namespace   = kubernetes_namespace_v1.infra.metadata[0].name
    annotations = local.minio_ingress_annotations
    labels = {
      "app.kubernetes.io/name" = "minio"
    }
  }
  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [local.minio_host]
      secret_name = kubernetes_secret_v1.minio_tls.metadata[0].name
    }

    rule {
      host = local.minio_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.minio.metadata[0].name
              port {
                number = 9000
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.ingress_nginx]
}

resource "kubernetes_ingress_v1" "minio_console" {
  metadata {
    name        = "minio-console-ingress"
    namespace   = kubernetes_namespace_v1.infra.metadata[0].name
    annotations = local.minio_ingress_annotations
    labels = {
      "app.kubernetes.io/name" = "minio"
    }
  }
  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [local.minio_console_host]
      secret_name = kubernetes_secret_v1.minio_tls.metadata[0].name
    }

    rule {
      host = local.minio_console_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.minio.metadata[0].name
              port {
                number = 9001
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.ingress_nginx]
}
