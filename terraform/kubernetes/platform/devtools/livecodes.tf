# ---------------------------------------------------------------------------
# LiveCodes — self-hosted code playground, served at livecodes.noizu.com.
# Stateless; shares URLs via the shared Valkey (db 2). The full Redis DSN
# (with the Valkey password) lives in Infisical.
# ---------------------------------------------------------------------------
resource "kubernetes_deployment_v1" "livecodes" {
  metadata {
    name      = "livecodes"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "livecodes" })
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "livecodes" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { app = "livecodes" })
      }
      spec {
        node_selector = local.node_selector
        image_pull_secrets {
          name = "ops-registry-secret"
        }
        container {
          name              = "livecodes"
          image             = var.livecodes_image
          image_pull_policy = "Always"
          port {
            container_port = 80
            protocol       = "TCP"
          }
          env {
            name  = "PORT"
            value = "80"
          }
          env {
            name  = "SELF_HOSTED_SHARE"
            value = "true"
          }
          env {
            name  = "SELF_HOSTED_BROADCAST"
            value = "true"
          }
          env {
            name  = "BROADCAST_PORT"
            value = "3030"
          }
          env {
            name = "REDIS_URL"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = "LIVECODES_REDIS_URL"
              }
            }
          }
          resources {
            requests = { cpu = "50m", memory = "128Mi" }
            limits   = { cpu = "1000m", memory = "1Gi" }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 10
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

  depends_on = [
    kubectl_manifest.infisical_app_secrets,
    kubectl_manifest.infisical_ops_pull,
  ]
}

resource "kubernetes_service_v1" "livecodes" {
  metadata {
    name      = "livecodes"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "livecodes" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "livecodes" }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "livecodes" {
  metadata {
    name      = "livecodes-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "livecodes" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.livecodes_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.livecodes_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.livecodes.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
