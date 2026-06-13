# ---------------------------------------------------------------------------
# SEOnaut — Go SEO auditing tool, served at seonaut.noizu.com.
# Uses the shared MariaDB (platform/init). The DB password is injected into the
# TOML config at startup via sed substitution (preserving the legacy pattern).
# ---------------------------------------------------------------------------
resource "kubernetes_config_map_v1" "seonaut_config" {
  metadata {
    name      = "seonaut-config"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "seonaut" })
  }
  data = {
    "config.toml" = <<-TOML
      [server]
      host = "0.0.0.0"
      port = 9000
      url = "https://${var.seonaut_domain}"

      [database]
      server = "${var.mariadb_host}"
      port = 3306
      user = "${var.seonaut_db_user}"
      password = "placeholder"
      database = "${var.seonaut_db_name}"

      [crawler]
      agent = "Mozilla/5.0 (compatible; SEOnautBot/1.0; +https://seonaut.org/bot)"

      [UI]
      language = "en"
      theme = "dark"
    TOML
  }
}

resource "kubernetes_deployment_v1" "seonaut" {
  metadata {
    name      = "seonaut"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "seonaut" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "seonaut" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { app = "seonaut" })
      }
      spec {
        node_selector = local.node_selector
        image_pull_secrets {
          name = "ops-registry-secret"
        }
        container {
          name  = "seonaut"
          image = var.seonaut_image

          port {
            container_port = 9000
            protocol       = "TCP"
          }

          env {
            name = "SEONAUT_DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = "SEONAUT_DB_PASSWORD"
              }
            }
          }

          command = ["/bin/sh", "-c"]
          args = [<<-SH
            cp /etc/seonaut/config.toml /app/config
            sed -i "s/placeholder/$${SEONAUT_DATABASE_PASSWORD}/" /app/config
            exec /app/seonaut
          SH
          ]

          volume_mount {
            name       = "config"
            mount_path = "/etc/seonaut/config.toml"
            sub_path   = "config.toml"
            read_only  = true
          }

          resources {
            requests = { cpu = "50m", memory = "128Mi" }
            limits   = { cpu = "1000m", memory = "1Gi" }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 9000
            }
            initial_delay_seconds = 15
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 9000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.seonaut_config.metadata[0].name
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

resource "kubernetes_service_v1" "seonaut" {
  metadata {
    name      = "seonaut"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "seonaut" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "seonaut" }
    port {
      port        = 9000
      target_port = 9000
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "seonaut" {
  metadata {
    name      = "seonaut-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "seonaut" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.seonaut_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.seonaut_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.seonaut.metadata[0].name
              port { number = 9000 }
            }
          }
        }
      }
    }
  }
}
