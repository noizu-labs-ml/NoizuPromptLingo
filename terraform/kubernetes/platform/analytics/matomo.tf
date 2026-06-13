# ---------------------------------------------------------------------------
# Matomo — web analytics, served at matomo.noizu.com. Uses the shared MariaDB
# (platform/init).
# ---------------------------------------------------------------------------
resource "kubernetes_persistent_volume_claim_v1" "matomo_data" {
  metadata {
    name      = "matomo-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "matomo" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = var.matomo_storage }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "matomo" {
  metadata {
    name      = "matomo"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "matomo" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "matomo" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { app = "matomo" })
      }
      spec {
        node_selector = local.node_selector
        container {
          name  = "matomo"
          image = var.matomo_image
          port {
            container_port = 80
            protocol       = "TCP"
          }
          env {
            name  = "MATOMO_DATABASE_HOST"
            value = var.mariadb_host
          }
          env {
            name  = "MATOMO_DATABASE_PORT"
            value = "3306"
          }
          env {
            name  = "MATOMO_DATABASE_DBNAME"
            value = var.matomo_db_name
          }
          env {
            name  = "MATOMO_DATABASE_USERNAME"
            value = var.matomo_db_user
          }
          env {
            name = "MATOMO_DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = "MATOMO_DB_PASSWORD"
              }
            }
          }
          volume_mount {
            name       = "data"
            mount_path = "/var/www/html"
          }
          resources {
            requests = { cpu = "100m", memory = "512Mi" }
            limits   = { cpu = "2000m", memory = "4Gi" }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 15
            period_seconds        = 10
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.matomo_data.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical_app_secrets]
}

resource "kubernetes_service_v1" "matomo" {
  metadata {
    name      = "matomo"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "matomo" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "matomo" }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "matomo" {
  metadata {
    name      = "matomo-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "matomo" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size" = "50m"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.matomo_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.matomo_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.matomo.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
