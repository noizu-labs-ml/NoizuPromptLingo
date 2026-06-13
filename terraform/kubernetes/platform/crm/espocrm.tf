# ---------------------------------------------------------------------------
# EspoCRM — served at espocrm.noizu.com. Uses the shared MariaDB (platform/init).
# ---------------------------------------------------------------------------
resource "kubernetes_persistent_volume_claim_v1" "espocrm_data" {
  metadata {
    name      = "espocrm-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "espocrm" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = var.espocrm_storage }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "espocrm" {
  metadata {
    name      = "espocrm"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "espocrm" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "espocrm" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { app = "espocrm" })
      }
      spec {
        node_selector = local.node_selector
        image_pull_secrets {
          name = "ops-registry-secret"
        }
        container {
          name  = "espocrm"
          image = var.espocrm_image

          port {
            container_port = 80
            protocol       = "TCP"
          }

          env {
            name  = "ESPOCRM_DATABASE_HOST"
            value = var.mariadb_host
          }
          env {
            name  = "ESPOCRM_DATABASE_PORT"
            value = "3306"
          }
          env {
            name  = "ESPOCRM_DATABASE_NAME"
            value = var.espocrm_db_name
          }
          env {
            name  = "ESPOCRM_DATABASE_USER"
            value = var.espocrm_db_user
          }
          env {
            name  = "ESPOCRM_SITE_URL"
            value = "https://${var.espocrm_domain}"
          }
          dynamic "env" {
            for_each = {
              ESPOCRM_DATABASE_PASSWORD = "ESPOCRM_DB_PASSWORD"
              ESPOCRM_ADMIN_USERNAME    = "ESPOCRM_ADMIN_USERNAME"
              ESPOCRM_ADMIN_PASSWORD    = "ESPOCRM_ADMIN_PASSWORD"
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
            claim_name = kubernetes_persistent_volume_claim_v1.espocrm_data.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    kubectl_manifest.infisical_app_secrets,
    kubectl_manifest.infisical_ops_pull,
  ]
}

resource "kubernetes_service_v1" "espocrm" {
  metadata {
    name      = "espocrm"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "espocrm" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "espocrm" }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "espocrm" {
  metadata {
    name      = "espocrm-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "espocrm" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size" = "50m"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.espocrm_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.espocrm_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.espocrm.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
