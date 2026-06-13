# ---------------------------------------------------------------------------
# GrowthBook — feature flags / A-B testing, served at growthbook.noizu.com.
# Uses the shared MongoDB (platform/init); the full URI lives in Infisical.
# ---------------------------------------------------------------------------
resource "kubernetes_deployment_v1" "growthbook" {
  metadata {
    name      = "growthbook"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "growthbook" })
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "growthbook" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { app = "growthbook" })
      }
      spec {
        node_selector = local.node_selector
        image_pull_secrets {
          name = "ops-registry-secret"
        }
        container {
          name  = "growthbook"
          image = var.growthbook_image
          port {
            container_port = 3100
            protocol       = "TCP"
          }
          env {
            name  = "APP_ORIGIN"
            value = "https://${var.growthbook_domain}"
          }
          env {
            name  = "API_HOST"
            value = "https://${var.growthbook_domain}"
          }
          dynamic "env" {
            for_each = {
              MONGODB_URI    = "GROWTHBOOK_MONGODB_URI"
              JWT_SECRET     = "GROWTHBOOK_JWT_SECRET"
              ENCRYPTION_KEY = "GROWTHBOOK_ENCRYPTION_KEY"
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
          resources {
            requests = { cpu = "100m", memory = "512Mi" }
            limits   = { cpu = "2000m", memory = "4Gi" }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 3100
            }
            initial_delay_seconds = 15
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 3100
            }
            initial_delay_seconds = 10
            period_seconds        = 10
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

resource "kubernetes_service_v1" "growthbook" {
  metadata {
    name      = "growthbook"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "growthbook" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "growthbook" }
    port {
      port        = 3100
      target_port = 3100
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "growthbook" {
  metadata {
    name      = "growthbook-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "growthbook" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.growthbook_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.growthbook_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.growthbook.metadata[0].name
              port { number = 3100 }
            }
          }
        }
      }
    }
  }
}
