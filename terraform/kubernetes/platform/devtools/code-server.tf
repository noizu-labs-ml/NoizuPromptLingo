# ---------------------------------------------------------------------------
# code-server — VS Code in the browser, served at code.noizu.com. Self-contained
# with a large workspace PVC mounted at /config.
# ---------------------------------------------------------------------------
resource "kubernetes_persistent_volume_claim_v1" "code_server_data" {
  metadata {
    name      = "code-server-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "code-server" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = var.code_server_storage }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "code_server" {
  metadata {
    name      = "code-server"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "code-server" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "code-server" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { app = "code-server" })
      }
      spec {
        node_selector = local.node_selector
        container {
          name  = "code-server"
          image = var.code_server_image
          port {
            container_port = 8443
            protocol       = "TCP"
          }
          env {
            name  = "PUID"
            value = "1000"
          }
          env {
            name  = "PGID"
            value = "1000"
          }
          env {
            name  = "TZ"
            value = var.code_server_tz
          }
          env {
            name  = "DEFAULT_WORKSPACE"
            value = "/config/workspace"
          }
          env {
            name = "PASSWORD"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = "CODE_SERVER_PASSWORD"
              }
            }
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
          resources {
            requests = { cpu = "200m", memory = "512Mi" }
            limits   = { cpu = "4000m", memory = "8Gi" }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 8443
            }
            initial_delay_seconds = 10
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 8443
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.code_server_data.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.infisical_app_secrets]
}

resource "kubernetes_service_v1" "code_server" {
  metadata {
    name      = "code-server"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "code-server" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "code-server" }
    port {
      port        = 8443
      target_port = 8443
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "code_server" {
  metadata {
    name      = "code-server-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "code-server" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "100m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "3600"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "3600"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.code_server_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.code_server_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.code_server.metadata[0].name
              port { number = 8443 }
            }
          }
        }
      }
    }
  }
}
