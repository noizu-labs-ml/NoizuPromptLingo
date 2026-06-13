# ---------------------------------------------------------------------------
# Mautic — marketing automation, served at mautic.noizu.com. Uses the shared
# MariaDB (platform/init). Persists config/var/media on one PVC via subPaths.
# ---------------------------------------------------------------------------
resource "kubernetes_persistent_volume_claim_v1" "mautic_data" {
  metadata {
    name      = "mautic-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "mautic" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = var.mautic_storage }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "mautic" {
  metadata {
    name      = "mautic"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "mautic" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "mautic" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { app = "mautic" })
      }
      spec {
        node_selector = local.node_selector
        container {
          name  = "mautic"
          image = var.mautic_image
          port {
            container_port = 80
            protocol       = "TCP"
          }
          env {
            name  = "MAUTIC_DB_HOST"
            value = var.mariadb_host
          }
          env {
            name  = "MAUTIC_DB_PORT"
            value = "3306"
          }
          env {
            name  = "MAUTIC_DB_NAME"
            value = var.mautic_db_name
          }
          env {
            name  = "MAUTIC_DB_USER"
            value = var.mautic_db_user
          }
          env {
            name  = "DOCKER_MAUTIC_ROLE"
            value = "mautic_web"
          }
          dynamic "env" {
            for_each = {
              MAUTIC_DB_PASSWORD = "MAUTIC_DB_PASSWORD"
              MAUTIC_SECRET_KEY  = "MAUTIC_SECRET_KEY"
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
          volume_mount {
            name       = "data"
            mount_path = "/var/www/html/config"
            sub_path   = "config"
          }
          volume_mount {
            name       = "data"
            mount_path = "/var/www/html/var"
            sub_path   = "var"
          }
          volume_mount {
            name       = "data"
            mount_path = "/var/www/html/docroot/media"
            sub_path   = "media"
          }
          resources {
            requests = { cpu = "200m", memory = "512Mi" }
            limits   = { cpu = "2000m", memory = "8Gi" }
          }
          liveness_probe {
            tcp_socket { port = 80 }
            initial_delay_seconds = 120
            period_seconds        = 60
            failure_threshold     = 20
          }
          readiness_probe {
            tcp_socket { port = 80 }
            initial_delay_seconds = 30
            period_seconds        = 15
            failure_threshold     = 10
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.mautic_data.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical_app_secrets]
}

resource "kubernetes_service_v1" "mautic" {
  metadata {
    name      = "mautic"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "mautic" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "mautic" }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "mautic" {
  metadata {
    name      = "mautic-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "mautic" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size" = "50m"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.mautic_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.mautic_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.mautic.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
