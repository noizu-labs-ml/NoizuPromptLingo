# Excalidraw — collaborative whiteboard, served at excalidraw.noizu.com.
# Frontend (static) + room server (WebSocket, backed by the shared Valkey db 1).
resource "kubernetes_deployment_v1" "excalidraw_frontend" {
  metadata {
    name      = "excalidraw-frontend"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "excalidraw-frontend" })
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "excalidraw-frontend" } }
    template {
      metadata { labels = merge(local.common_labels, { app = "excalidraw-frontend" }) }
      spec {
        node_selector = local.node_selector
        image_pull_secrets { name = "ops-registry-secret" }
        container {
          name  = "frontend"
          image = var.excalidraw_frontend_image
          port {
            container_port = 80
            name           = "http"
          }
          env {
            name  = "VITE_APP_WS_SERVER_URL"
            value = "wss://${var.excalidraw_domain}"
          }
          env {
            name  = "VITE_APP_HTTP_STORAGE_BACKEND_URL"
            value = "https://${var.excalidraw_domain}/api/v2"
          }
          env {
            name  = "VITE_APP_BACKEND_V2_GET_URL"
            value = "https://${var.excalidraw_domain}/api/v2/scenes/"
          }
          env {
            name  = "VITE_APP_BACKEND_V2_POST_URL"
            value = "https://${var.excalidraw_domain}/api/v2/scenes/"
          }
          env {
            name  = "VITE_APP_STORAGE_BACKEND"
            value = "https"
          }
          resources {
            requests = { cpu = "50m", memory = "128Mi" }
            limits   = { cpu = "250m", memory = "512Mi" }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 15
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
  depends_on = [kubectl_manifest.infisical_ops_pull]
}

resource "kubernetes_deployment_v1" "excalidraw_room" {
  metadata {
    name      = "excalidraw-room"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "excalidraw-room" })
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "excalidraw-room" } }
    template {
      metadata { labels = merge(local.common_labels, { app = "excalidraw-room" }) }
      spec {
        node_selector = local.node_selector
        image_pull_secrets { name = "ops-registry-secret" }
        container {
          name  = "room"
          image = var.excalidraw_room_image
          port {
            container_port = 80
            name           = "http"
          }
          env {
            name  = "REDIS_HOSTNAME"
            value = var.valkey_host
          }
          env {
            name  = "REDIS_PORT"
            value = "6379"
          }
          env {
            name  = "REDIS_DB"
            value = var.excalidraw_redis_db
          }
          env {
            name = "REDIS_PASSWORD"
            value_from {
              secret_key_ref {
                name = "excalidraw-secrets"
                key  = "EXCALIDRAW_REDIS_PASSWORD"
              }
            }
          }
          resources {
            requests = { cpu = "50m", memory = "128Mi" }
            limits   = { cpu = "250m", memory = "512Mi" }
          }
          readiness_probe {
            tcp_socket { port = 80 }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
  depends_on = [kubectl_manifest.infisical_app]
}

resource "kubernetes_service_v1" "excalidraw_frontend" {
  metadata {
    name      = "excalidraw-frontend"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "excalidraw-frontend" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "excalidraw-frontend" }
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_service_v1" "excalidraw_room" {
  metadata {
    name      = "excalidraw-room"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "excalidraw-room" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "excalidraw-room" }
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "excalidraw" {
  metadata {
    name      = "excalidraw-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "excalidraw" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "50m"
      "nginx.ingress.kubernetes.io/proxy-http-version" = "1.1"
      "nginx.ingress.kubernetes.io/upstream-hash-by"   = "$remote_addr"
      "nginx.ingress.kubernetes.io/enable-websocket"   = "true"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.excalidraw_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.excalidraw_domain
      http {
        path {
          path      = "/socket.io"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = kubernetes_service_v1.excalidraw_room.metadata[0].name
              port { number = 80 }
            }
          }
        }
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.excalidraw_frontend.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
