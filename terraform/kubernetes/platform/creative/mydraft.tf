# MyDraft — wireframing tool, served at mydraft.noizu.com. Persists a local file
# store on a PVC (RWO, hence Recreate).
resource "kubernetes_persistent_volume_claim_v1" "mydraft_data" {
  metadata {
    name      = "mydraft-data"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "mydraft" })
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = local.storage_class
    resources {
      requests = { storage = var.mydraft_storage }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment_v1" "mydraft" {
  metadata {
    name      = "mydraft"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "mydraft" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector { match_labels = { app = "mydraft" } }
    template {
      metadata { labels = merge(local.common_labels, { app = "mydraft" }) }
      spec {
        node_selector = local.node_selector
        image_pull_secrets { name = "ops-registry-secret" }
        init_container {
          name    = "fix-permissions"
          image   = "busybox:latest"
          command = ["sh", "-c", "chmod -R 777 /data"]
          security_context { run_as_user = 0 }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }
        container {
          name  = "mydraft"
          image = var.mydraft_image
          port {
            container_port = 8001
            name           = "http"
          }
          volume_mount {
            name       = "data"
            mount_path = "/mydraft/localFileStore"
          }
          resources {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "500m", memory = "1Gi" }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 8001
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 8001
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.mydraft_data.metadata[0].name
          }
        }
      }
    }
  }
  depends_on = [kubectl_manifest.infisical_ops_pull]
}

resource "kubernetes_service_v1" "mydraft" {
  metadata {
    name      = "mydraft"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "mydraft" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "mydraft" }
    port {
      port        = 80
      target_port = 8001
    }
  }
}

resource "kubernetes_ingress_v1" "mydraft" {
  metadata {
    name        = "mydraft-ingress"
    namespace   = local.ns
    labels      = merge(local.common_labels, { app = "mydraft" })
    annotations = local.cf_annotations
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.mydraft_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.mydraft_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.mydraft.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
