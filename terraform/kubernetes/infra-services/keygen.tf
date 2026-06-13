# ---------------------------------------------------------------------------
# Keygen — software licensing API, proxied to api.keygen.sh. Runs in proxy mode:
# an nginx reverse proxy. Served at keygen.noizu.com + keygen.derobot.is.
# (Self-hosted mode from the legacy chart is omitted; re-add with its own DB if
# ever needed.)
# ---------------------------------------------------------------------------
resource "kubernetes_config_map_v1" "keygen_nginx" {
  metadata {
    name      = "keygen-nginx-config"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "keygen" })
  }
  data = {
    "default.conf" = <<-CONF
      upstream keygen_api {
        server api.keygen.sh:443;
      }

      server {
        listen 80;

        location /healthz {
          access_log off;
          return 200 "ok";
        }

        location / {
          proxy_pass https://api.keygen.sh;
          proxy_ssl_server_name on;
          proxy_set_header Host api.keygen.sh;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_connect_timeout 30s;
          proxy_read_timeout 300s;
          proxy_send_timeout 300s;
        }
      }
    CONF
  }
}

resource "kubernetes_deployment_v1" "keygen" {
  metadata {
    name      = "keygen"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "keygen" })
  }
  spec {
    replicas = 1
    selector {
      match_labels = { "app.kubernetes.io/name" = "keygen" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { "app.kubernetes.io/name" = "keygen" })
      }
      spec {
        node_selector = local.node_selector
        container {
          name  = "nginx"
          image = var.keygen_proxy_image
          port {
            container_port = 80
            name           = "http"
          }
          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx/conf.d/default.conf"
            sub_path   = "default.conf"
          }
          resources {
            requests = { cpu = "50m", memory = "32Mi" }
            limits   = { cpu = "200m", memory = "64Mi" }
          }
          liveness_probe {
            http_get {
              path = "/healthz"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 15
          }
          readiness_probe {
            http_get {
              path = "/healthz"
              port = 80
            }
            initial_delay_seconds = 2
            period_seconds        = 5
          }
        }
        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map_v1.keygen_nginx.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "keygen" {
  metadata {
    name      = "keygen"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "keygen" })
  }
  spec {
    type     = "ClusterIP"
    selector = { "app.kubernetes.io/name" = "keygen" }
    port {
      name        = "http"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "keygen" {
  metadata {
    name      = "keygen-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { "app.kubernetes.io/name" = "keygen" })
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"           = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size"        = "10m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout"     = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout"     = "300"
      "nginx.ingress.kubernetes.io/whitelist-source-range" = local.cloudflare_ip_whitelist
    }
  }
  spec {
    ingress_class_name = "nginx"
    # Per-host TLS secret: *.noizu.com hosts use the synced Cloudflare wildcard
    # (cloudflare-tls-synced, SANs *.noizu.com,noizu.com); *.derobot.is hosts use
    # the derobotis-tls wildcard (SANs *.derobot.is,derobot.is). Routing both to
    # cloudflare-tls-synced made keygen.derobot.is fall back to ingress-nginx's
    # self-signed "Fake Certificate" (cert/host SAN mismatch).
    dynamic "tls" {
      for_each = toset(var.keygen_domains)
      content {
        hosts       = [tls.value]
        secret_name = endswith(tls.value, ".derobot.is") ? "derobotis-tls" : "cloudflare-tls-synced"
      }
    }
    dynamic "rule" {
      for_each = toset(var.keygen_domains)
      content {
        host = rule.value
        http {
          path {
            path      = "/"
            path_type = "Prefix"
            backend {
              service {
                name = kubernetes_service_v1.keygen.metadata[0].name
                port { number = 80 }
              }
            }
          }
        }
      }
    }
  }
}
