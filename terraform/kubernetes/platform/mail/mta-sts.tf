# =============================================================================
# MTA-STS policy server (serves /.well-known/mta-sts.txt)
# =============================================================================
resource "kubernetes_deployment_v1" "mta_sts" {
  metadata {
    name      = "mta-sts"
    namespace = local.ns
    labels    = local.labels["mta-sts"]
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "mta-sts" }
    }
    template {
      metadata {
        labels = { app = "mta-sts" }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx:1.27-alpine"
          port {
            container_port = 80
          }
          volume_mount {
            name       = "config"
            mount_path = "/etc/nginx/conf.d/default.conf"
            sub_path   = "nginx.conf"
          }
          volume_mount {
            name       = "config"
            mount_path = "/usr/share/nginx/html/.well-known/mta-sts.txt"
            sub_path   = "mta-sts.txt"
          }
          resources {
            requests = { cpu = "10m", memory = "16Mi" }
            limits   = { cpu = "100m", memory = "64Mi" }
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.mta_sts.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "mta_sts" {
  metadata {
    name      = "mta-sts"
    namespace = local.ns
    labels    = local.labels["mta-sts"]
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "mta-sts" }
    port {
      port        = 80
      target_port = 80
    }
  }
}
