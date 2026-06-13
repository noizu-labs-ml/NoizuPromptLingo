# Penpot — design / prototyping platform, served at penpot.noizu.com. Frontend
# (nginx, proxies to backend+exporter in-cluster) + backend + exporter + a
# private embedded MinIO for asset storage. Postgres + Valkey come from
# platform/init via full DSNs in penpot-secrets (/creative/penpot).
locals {
  penpot_public_uri        = "https://${var.penpot_domain}"
  penpot_flags             = "enable-registration enable-login-with-password enable-login-with-google disable-email-verification disable-smtp disable-telemetry"
  penpot_internal_resolver = "10.0.0.254" # cluster DNS resolver (kube-dns/CoreDNS ClusterIP) — verify per cluster
  penpot_s3_endpoint       = "http://penpot-minio:9000"
  penpot_s3_bucket         = "penpot"
}

# ---- Embedded MinIO --------------------------------------------------------
resource "kubernetes_persistent_volume_claim_v1" "penpot_minio_data" {
  metadata {
    name      = "penpot-minio-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "penpot", component = "minio" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = var.penpot_minio_storage }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "penpot_minio" {
  metadata {
    name      = "penpot-minio"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "penpot", component = "minio" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector { match_labels = { app = "penpot", component = "minio" } }
    template {
      metadata { labels = merge(local.common_labels, { app = "penpot", component = "minio" }) }
      spec {
        node_selector = local.node_selector
        security_context {
          fs_group = 1000
        }
        init_container {
          name    = "fix-permissions"
          image   = "busybox:latest"
          command = ["sh", "-c", "chown -R 1000:1000 /data"]
          security_context { run_as_user = 0 }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }
        container {
          name    = "minio"
          image   = "minio/minio:RELEASE.2024-11-07T00-52-20Z"
          command = ["minio", "server", "/data", "--console-address", ":9001"]
          port {
            container_port = 9000
            name           = "api"
          }
          port {
            container_port = 9001
            name           = "console"
          }
          dynamic "env" {
            for_each = {
              MINIO_ROOT_USER     = "MINIO_ROOT_USER"
              MINIO_ROOT_PASSWORD = "MINIO_ROOT_PASSWORD"
            }
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = "penpot-secrets"
                  key  = env.value
                }
              }
            }
          }
          resources {
            requests = { cpu = "200m", memory = "512Mi" }
            limits   = { cpu = "1000m", memory = "2Gi" }
          }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
          liveness_probe {
            http_get {
              path = "/minio/health/live"
              port = 9000
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/minio/health/ready"
              port = 9000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.penpot_minio_data.metadata[0].name
          }
        }
      }
    }
  }
  depends_on = [kubectl_manifest.infisical_app]
}

resource "kubernetes_service_v1" "penpot_minio" {
  metadata {
    name      = "penpot-minio"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "penpot", component = "minio" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "penpot", component = "minio" }
    port {
      port        = 9000
      target_port = 9000
      name        = "api"
    }
    port {
      port        = 9001
      target_port = 9001
      name        = "console"
    }
  }
}

# One-shot bucket creation (idempotent). Delete this Job to re-run.
resource "kubernetes_job_v1" "penpot_minio_init" {
  metadata {
    name      = "penpot-minio-init"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "penpot", component = "minio-init" })
  }
  spec {
    backoff_limit              = 5
    active_deadline_seconds    = 180
    ttl_seconds_after_finished = 600
    template {
      metadata { labels = { app = "penpot-minio-init" } }
      spec {
        restart_policy = "OnFailure"
        container {
          name    = "mc"
          image   = "minio/mc:RELEASE.2024-11-17T19-35-25Z"
          command = ["/bin/sh", "-c", "until mc alias set local ${local.penpot_s3_endpoint} \"$MINIO_ROOT_USER\" \"$MINIO_ROOT_PASSWORD\" 2>/dev/null; do echo 'Waiting for MinIO...'; sleep 5; done; mc mb --ignore-existing local/${local.penpot_s3_bucket}; echo 'Bucket ready.'"]
          dynamic "env" {
            for_each = {
              MINIO_ROOT_USER     = "MINIO_ROOT_USER"
              MINIO_ROOT_PASSWORD = "MINIO_ROOT_PASSWORD"
            }
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = "penpot-secrets"
                  key  = env.value
                }
              }
            }
          }
        }
      }
    }
  }
  wait_for_completion = false
  depends_on          = [kubernetes_deployment_v1.penpot_minio]
}

# ---- Backend ---------------------------------------------------------------
resource "kubernetes_deployment_v1" "penpot_backend" {
  metadata {
    name      = "penpot-backend"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "penpot", component = "backend" })
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "penpot", component = "backend" } }
    template {
      metadata { labels = merge(local.common_labels, { app = "penpot", component = "backend" }) }
      spec {
        node_selector = local.node_selector
        image_pull_secrets { name = "ops-registry-secret" }
        container {
          name  = "penpot-backend"
          image = "penpotapp/backend:2.4.2"
          port {
            container_port = 6060
            name           = "http"
          }
          env {
            name  = "PENPOT_PUBLIC_URI"
            value = local.penpot_public_uri
          }
          env {
            name  = "PENPOT_FLAGS"
            value = local.penpot_flags
          }
          env {
            name  = "PENPOT_ASSETS_STORAGE_BACKEND"
            value = "assets-s3"
          }
          env {
            name  = "PENPOT_STORAGE_ASSETS_S3_BUCKET"
            value = local.penpot_s3_bucket
          }
          env {
            name  = "PENPOT_STORAGE_ASSETS_S3_ENDPOINT"
            value = local.penpot_s3_endpoint
          }
          env {
            name  = "PENPOT_STORAGE_ASSETS_S3_REGION"
            value = "us-east-1"
          }
          env {
            name  = "PENPOT_TELEMETRY_ENABLED"
            value = "false"
          }
          dynamic "env" {
            for_each = {
              PENPOT_SECRET_KEY           = "PENPOT_SECRET_KEY"
              PENPOT_GOOGLE_CLIENT_ID     = "PENPOT_GOOGLE_CLIENT_ID"
              PENPOT_GOOGLE_CLIENT_SECRET = "PENPOT_GOOGLE_CLIENT_SECRET"
              PENPOT_DATABASE_URI         = "PENPOT_DATABASE_URI"
              PENPOT_DATABASE_USERNAME    = "PENPOT_DATABASE_USERNAME"
              PENPOT_DATABASE_PASSWORD    = "PENPOT_DATABASE_PASSWORD"
              PENPOT_REDIS_URI            = "PENPOT_REDIS_URI"
              AWS_ACCESS_KEY_ID           = "MINIO_ROOT_USER"
              AWS_SECRET_ACCESS_KEY       = "MINIO_ROOT_PASSWORD"
            }
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = "penpot-secrets"
                  key  = env.value
                }
              }
            }
          }
          resources {
            requests = { cpu = "500m", memory = "1Gi" }
            limits   = { cpu = "2000m", memory = "4Gi" }
          }
          liveness_probe {
            http_get {
              path = "/readyz"
              port = 6060
            }
            initial_delay_seconds = 120
            period_seconds        = 60
            timeout_seconds       = 15
            failure_threshold     = 20
          }
          readiness_probe {
            http_get {
              path = "/readyz"
              port = 6060
            }
            initial_delay_seconds = 30
            period_seconds        = 15
            timeout_seconds       = 10
            failure_threshold     = 10
          }
        }
      }
    }
  }
  depends_on = [kubectl_manifest.infisical_app]
}

# ---- Exporter --------------------------------------------------------------
resource "kubernetes_deployment_v1" "penpot_exporter" {
  metadata {
    name      = "penpot-exporter"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "penpot", component = "exporter" })
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "penpot", component = "exporter" } }
    template {
      metadata { labels = merge(local.common_labels, { app = "penpot", component = "exporter" }) }
      spec {
        node_selector = local.node_selector
        image_pull_secrets { name = "ops-registry-secret" }
        container {
          name  = "penpot-exporter"
          image = "penpotapp/exporter:2.4.2"
          port {
            container_port = 6061
            name           = "http"
          }
          env {
            name  = "PENPOT_PUBLIC_URI"
            value = local.penpot_public_uri
          }
          env {
            name = "PENPOT_REDIS_URI"
            value_from {
              secret_key_ref {
                name = "penpot-secrets"
                key  = "PENPOT_REDIS_URI"
              }
            }
          }
          resources {
            requests = { cpu = "250m", memory = "512Mi" }
            limits   = { cpu = "1000m", memory = "2Gi" }
          }
          liveness_probe {
            tcp_socket { port = 6061 }
            initial_delay_seconds = 60
            period_seconds        = 30
          }
          readiness_probe {
            tcp_socket { port = 6061 }
            initial_delay_seconds = 15
            period_seconds        = 10
          }
        }
      }
    }
  }
  depends_on = [kubectl_manifest.infisical_app]
}

# ---- Frontend --------------------------------------------------------------
resource "kubernetes_deployment_v1" "penpot_frontend" {
  metadata {
    name      = "penpot-frontend"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "penpot", component = "frontend" })
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "penpot", component = "frontend" } }
    template {
      metadata { labels = merge(local.common_labels, { app = "penpot", component = "frontend" }) }
      spec {
        node_selector = local.node_selector
        image_pull_secrets { name = "ops-registry-secret" }
        container {
          name  = "penpot-frontend"
          image = "penpotapp/frontend:2.4.2"
          port {
            container_port = 8080
            name           = "http"
          }
          env {
            name  = "PENPOT_PUBLIC_URI"
            value = local.penpot_public_uri
          }
          env {
            name  = "PENPOT_FLAGS"
            value = local.penpot_flags
          }
          env {
            name  = "PENPOT_BACKEND_URI"
            value = "http://penpot-backend:6060"
          }
          env {
            name  = "PENPOT_EXPORTER_URI"
            value = "http://penpot-exporter:6061"
          }
          env {
            name  = "PENPOT_INTERNAL_RESOLVER"
            value = local.penpot_internal_resolver
          }
          resources {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "500m", memory = "512Mi" }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 8080
              http_header {
                name  = "Host"
                value = var.penpot_domain
              }
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 8080
              http_header {
                name  = "Host"
                value = var.penpot_domain
              }
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
      }
    }
  }
  depends_on = [
    kubectl_manifest.infisical_ops_pull,
    kubernetes_deployment_v1.penpot_backend,
  ]
}

resource "kubernetes_service_v1" "penpot_frontend" {
  metadata {
    name      = "penpot-frontend"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "penpot", component = "frontend" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "penpot", component = "frontend" }
    port {
      port        = 80
      target_port = 8080
    }
  }
}

resource "kubernetes_service_v1" "penpot_backend" {
  metadata {
    name      = "penpot-backend"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "penpot", component = "backend" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "penpot", component = "backend" }
    port {
      port        = 6060
      target_port = 6060
    }
  }
}

resource "kubernetes_service_v1" "penpot_exporter" {
  metadata {
    name      = "penpot-exporter"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "penpot", component = "exporter" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "penpot", component = "exporter" }
    port {
      port        = 6061
      target_port = 6061
    }
  }
}

resource "kubernetes_ingress_v1" "penpot" {
  metadata {
    name      = "penpot-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "penpot" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "100m"
      "nginx.ingress.kubernetes.io/proxy-http-version" = "1.1"
      "nginx.ingress.kubernetes.io/enable-websocket"   = "true"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "300"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.penpot_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.penpot_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.penpot_frontend.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
