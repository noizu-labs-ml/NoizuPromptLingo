# ---------------------------------------------------------------------------
# Docker registry — served at ops.noizu.com (basic-auth at the ingress).
# ---------------------------------------------------------------------------
# Basic auth uses registry-basic-auth (htpasswd) and TLS uses the dedicated
# ops.noizu.com cert (ops-noizu-com-tls). Both are sealed secrets — see
# secrets.tf (registry-basic-auth via seal-managed-secrets.sh, the TLS cert via
# seal-secrets.sh).
locals {
  registry_host = "ops.noizu.com"
}

resource "kubernetes_persistent_volume_claim_v1" "registry" {
  metadata {
    name      = "registry-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "registry" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = "500Gi" }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "registry" {
  metadata {
    name      = "registry"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "registry" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { "app.kubernetes.io/name" = "registry" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "registry" })
      }
      spec {
        node_selector = local.node_selector
        container {
          name  = "registry"
          image = "registry:2"

          port {
            container_port = 5000
          }

          env {
            name  = "REGISTRY_STORAGE_DELETE_ENABLED"
            value = "true"
          }

          volume_mount {
            name       = "registry-data"
            mount_path = "/var/lib/registry"
            sub_path   = "registry"
          }

          liveness_probe {
            http_get {
              path = "/v2/"
              port = 5000
            }
            initial_delay_seconds = 10
            period_seconds        = 30
            timeout_seconds       = 1
          }
          readiness_probe {
            http_get {
              path = "/v2/"
              port = 5000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 1
          }
        }

        volume {
          name = "registry-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.registry.metadata[0].name
          }
        }
      }
    }
  }

  timeouts {
    create = "10m"
    update = "10m"
  }
}

resource "kubernetes_service_v1" "registry" {
  metadata {
    name      = "registry-service"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "registry" })
  }
  spec {
    selector = { "app.kubernetes.io/name" = "registry" }
    port {
      name        = "http"
      port        = 80
      target_port = 5000
    }
  }
}

resource "kubernetes_ingress_v1" "registry" {
  metadata {
    name      = "registry-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "registry" })
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/auth-type"          = "basic"
      "nginx.ingress.kubernetes.io/auth-secret"        = "registry-basic-auth"
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "10g"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "300"
    }
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [local.registry_host]
      secret_name = "ops-noizu-com-tls"
    }
    rule {
      host = local.registry_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.registry.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.sealed]
}
