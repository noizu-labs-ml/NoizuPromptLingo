# Kroki — unified diagram-rendering API, served at kroki.noizu.com. Gateway +
# companion renderers (mermaid/bpmn/excalidraw/diagramsnet) in one pod. Stateless.
locals {
  kroki_companions = {
    "kroki-mermaid"     = { image = var.kroki_mermaid_image, port = 8002 }
    "kroki-bpmn"        = { image = var.kroki_bpmn_image, port = 8003 }
    "kroki-excalidraw"  = { image = var.kroki_excalidraw_image, port = 8004 }
    "kroki-diagramsnet" = { image = var.kroki_diagramsnet_image, port = 8005 }
  }
}

resource "kubernetes_deployment_v1" "kroki" {
  metadata {
    name      = "kroki"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "kroki" })
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "kroki" } }
    template {
      metadata { labels = merge(local.common_labels, { app = "kroki" }) }
      spec {
        node_selector = local.node_selector
        image_pull_secrets { name = "ops-registry-secret" }

        container {
          name  = "kroki"
          image = var.kroki_image
          port {
            container_port = 8000
            name           = "http"
          }
          env {
            name  = "KROKI_MERMAID_HOST"
            value = "localhost"
          }
          env {
            name  = "KROKI_BPMN_HOST"
            value = "localhost"
          }
          env {
            name  = "KROKI_EXCALIDRAW_HOST"
            value = "localhost"
          }
          env {
            name  = "KROKI_DIAGRAMSNET_HOST"
            value = "localhost"
          }
          resources {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "500m", memory = "1Gi" }
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }

        dynamic "container" {
          for_each = local.kroki_companions
          content {
            name  = container.key
            image = container.value.image
            port {
              container_port = container.value.port
            }
            resources {
              requests = { cpu = "50m", memory = "128Mi" }
              limits   = { cpu = "250m", memory = "512Mi" }
            }
          }
        }
      }
    }
  }
  depends_on = [kubectl_manifest.infisical_ops_pull]
}

resource "kubernetes_service_v1" "kroki" {
  metadata {
    name      = "kroki"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "kroki" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "kroki" }
    port {
      port        = 80
      target_port = 8000
      name        = "http"
    }
  }
}

resource "kubernetes_ingress_v1" "kroki" {
  metadata {
    name        = "kroki-ingress"
    namespace   = local.ns
    labels      = merge(local.common_labels, { app = "kroki" })
    annotations = local.cf_annotations
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.kroki_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.kroki_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.kroki.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
