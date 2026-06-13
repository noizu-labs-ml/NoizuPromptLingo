# ---------------------------------------------------------------------------
# Nextcloud — file sync / collaboration, served at nextcloud.noizu.com. Shared
# Postgres + Valkey (platform/init); data on a dedicated 100Gi PVC. Runs as the
# www-data uid/gid (33).
# ---------------------------------------------------------------------------
resource "kubernetes_persistent_volume_claim_v1" "nextcloud_data" {
  metadata {
    name      = "nextcloud-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "nextcloud" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = var.nextcloud_storage }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "nextcloud" {
  metadata {
    name      = "nextcloud"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "nextcloud" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "nextcloud" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { app = "nextcloud" })
      }
      spec {
        node_selector = local.node_selector
        security_context {
          fs_group = 33
        }
        init_container {
          name    = "fix-permissions"
          image   = "busybox:1.36"
          command = ["sh", "-c", "chown -R 33:33 /var/www/html"]
          security_context { run_as_user = 0 }
          volume_mount {
            name       = "data"
            mount_path = "/var/www/html"
          }
        }
        container {
          name  = "nextcloud"
          image = var.nextcloud_image
          port {
            container_port = 80
            name           = "http"
          }
          env {
            name  = "POSTGRES_HOST"
            value = var.postgres_host
          }
          env {
            name  = "POSTGRES_DB"
            value = var.nextcloud_db_name
          }
          env {
            name  = "REDIS_HOST"
            value = var.valkey_host
          }
          env {
            name  = "NEXTCLOUD_TRUSTED_DOMAINS"
            value = var.nextcloud_domain
          }
          env {
            name  = "OVERWRITEPROTOCOL"
            value = "https"
          }
          env {
            name  = "OVERWRITEHOST"
            value = var.nextcloud_domain
          }
          env {
            name  = "SMTP_SECURE"
            value = "tls"
          }
          env {
            name  = "SMTP_AUTHTYPE"
            value = "LOGIN"
          }
          # Required DB credentials.
          dynamic "env" {
            for_each = {
              POSTGRES_USER     = "NEXTCLOUD_DB_USER"
              POSTGRES_PASSWORD = "NEXTCLOUD_DB_PASSWORD"
            }
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = var.managed_secret_name
                  key  = env.value
                }
              }
            }
          }
          # Optional: Valkey password, admin bootstrap, SMTP.
          dynamic "env" {
            for_each = {
              REDIS_HOST_PASSWORD      = "NEXTCLOUD_REDIS_PASSWORD"
              NEXTCLOUD_ADMIN_USER     = "NEXTCLOUD_ADMIN_USER"
              NEXTCLOUD_ADMIN_PASSWORD = "NEXTCLOUD_ADMIN_PASSWORD"
              SMTP_HOST                = "SMTP_HOST"
              SMTP_PORT                = "SMTP_PORT"
              SMTP_NAME                = "SMTP_USER"
              SMTP_PASSWORD            = "SMTP_PASSWORD"
              MAIL_FROM_ADDRESS        = "SMTP_FROM"
            }
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name     = var.managed_secret_name
                  key      = env.value
                  optional = true
                }
              }
            }
          }
          volume_mount {
            name       = "data"
            mount_path = "/var/www/html"
          }
          resources {
            requests = { cpu = "200m", memory = "256Mi" }
            limits   = { cpu = "1000m", memory = "1Gi" }
          }
          liveness_probe {
            http_get {
              path = "/status.php"
              port = 80
              http_header {
                name  = "Host"
                value = var.nextcloud_domain
              }
            }
            initial_delay_seconds = 120
            period_seconds        = 30
            timeout_seconds       = 10
          }
          readiness_probe {
            http_get {
              path = "/status.php"
              port = 80
              http_header {
                name  = "Host"
                value = var.nextcloud_domain
              }
            }
            initial_delay_seconds = 30
            period_seconds        = 15
            timeout_seconds       = 10
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.nextcloud_data.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical_app_secrets]
}

resource "kubernetes_service_v1" "nextcloud" {
  metadata {
    name      = "nextcloud"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "nextcloud" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "nextcloud" }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "nextcloud" {
  metadata {
    name      = "nextcloud-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "nextcloud" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "10G"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "600"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "600"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.nextcloud_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.nextcloud_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.nextcloud.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
