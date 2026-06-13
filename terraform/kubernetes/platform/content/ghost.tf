# ---------------------------------------------------------------------------
# Ghost — blog CMS, served at ghost.noizu.com. Uses the shared MariaDB
# (platform/init); content (themes, images) on a PVC.
# ---------------------------------------------------------------------------
resource "kubernetes_persistent_volume_claim_v1" "ghost_content" {
  metadata {
    name      = "ghost-content"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "ghost" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = var.ghost_storage }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "ghost" {
  metadata {
    name      = "ghost"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "ghost" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "ghost" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { app = "ghost" })
      }
      spec {
        node_selector = local.node_selector
        security_context {
          fs_group = 1000
        }
        init_container {
          name    = "fix-permissions"
          image   = "busybox:1.36"
          command = ["sh", "-c", "chown -R 1000:1000 /var/lib/ghost/content"]
          security_context { run_as_user = 0 }
          volume_mount {
            name       = "content"
            mount_path = "/var/lib/ghost/content"
          }
        }
        container {
          name  = "ghost"
          image = var.ghost_image
          port {
            container_port = 2368
            protocol       = "TCP"
          }
          env {
            name  = "url"
            value = "https://${var.ghost_domain}"
          }
          env {
            name  = "NODE_ENV"
            value = "production"
          }
          env {
            name  = "database__client"
            value = "mysql2"
          }
          env {
            name  = "database__connection__host"
            value = var.mariadb_host
          }
          env {
            name  = "database__connection__port"
            value = "3306"
          }
          env {
            name  = "database__connection__user"
            value = var.ghost_db_user
          }
          env {
            name  = "database__connection__database"
            value = var.ghost_db_name
          }
          env {
            name = "database__connection__password"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = "GHOST_DB_PASSWORD"
              }
            }
          }
          volume_mount {
            name       = "content"
            mount_path = "/var/lib/ghost/content"
          }
          resources {
            requests = { cpu = "200m", memory = "1Gi" }
            limits   = { cpu = "2000m", memory = "8Gi" }
          }
          liveness_probe {
            tcp_socket { port = 2368 }
            initial_delay_seconds = 120
            period_seconds        = 60
            failure_threshold     = 20
          }
          readiness_probe {
            tcp_socket { port = 2368 }
            initial_delay_seconds = 30
            period_seconds        = 15
            failure_threshold     = 10
          }
        }

        volume {
          name = "content"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.ghost_content.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical_app_secrets]
}

resource "kubernetes_service_v1" "ghost" {
  metadata {
    name      = "ghost"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "ghost" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "ghost" }
    port {
      port        = 2368
      target_port = 2368
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "ghost" {
  metadata {
    name      = "ghost-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "ghost" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "50m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "300"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.ghost_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.ghost_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.ghost.metadata[0].name
              port { number = 2368 }
            }
          }
        }
      }
    }
  }
}
