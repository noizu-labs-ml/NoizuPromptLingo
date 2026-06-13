# ---------------------------------------------------------------------------
# Headlamp — Kubernetes dashboard, served at headlamp.noizu.com.
# ---------------------------------------------------------------------------
# Runs in-cluster with a cluster-admin ServiceAccount.
locals {
  headlamp_host = "headlamp.noizu.com"
}

resource "kubernetes_service_account_v1" "headlamp" {
  metadata {
    name      = "headlamp-admin"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "headlamp" })
  }
}

resource "kubernetes_cluster_role_binding_v1" "headlamp" {
  metadata {
    name   = "headlamp-admin"
    labels = merge(local.common_labels, { "app.kubernetes.io/name" = "headlamp" })
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.headlamp.metadata[0].name
    namespace = local.ns
  }
}

resource "kubernetes_deployment_v1" "headlamp" {
  metadata {
    name      = "headlamp"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "headlamp" })
  }
  spec {
    replicas = 1
    selector {
      match_labels = { "app.kubernetes.io/name" = "headlamp" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "headlamp" })
      }
      spec {
        node_selector        = local.node_selector
        service_account_name = kubernetes_service_account_v1.headlamp.metadata[0].name
        container {
          name  = "headlamp"
          image = "ghcr.io/headlamp-k8s/headlamp:v0.42.0"
          args = [
            "-in-cluster",
            "-in-cluster-context-name=main",
            "-plugins-dir=/headlamp/plugins",
            "-session-ttl=86400",
          ]

          port {
            name           = "http"
            container_port = 4466
          }

          resources {
            requests = { cpu = "500m", memory = "512Mi" }
            limits   = { cpu = "2", memory = "2Gi" }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "http"
            }
            period_seconds  = 10
            timeout_seconds = 1
          }
          readiness_probe {
            http_get {
              path = "/"
              port = "http"
            }
            period_seconds  = 10
            timeout_seconds = 1
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "headlamp" {
  metadata {
    name      = "headlamp"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "headlamp" })
  }
  spec {
    selector = { "app.kubernetes.io/name" = "headlamp" }
    port {
      name        = "http"
      port        = 80
      target_port = 4466
    }
  }
}

resource "kubernetes_ingress_v1" "headlamp" {
  metadata {
    name      = "headlamp"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "headlamp" })
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [local.headlamp_host]
      secret_name = "cloudflare-tls-synced"
    }
    rule {
      host = local.headlamp_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.headlamp.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
