# Webstudio — visual web builder, served at webstudio.noizu.com. Builder + a
# PostgREST sidecar over the shared Postgres (platform/init). An init container
# mints a long-lived PostgREST JWT from the shared HMAC secret.
locals {
  webstudio_pg = "${var.postgres_host}:5432/${var.webstudio_db_name}"
}

resource "kubernetes_config_map_v1" "webstudio_config" {
  metadata {
    name      = "webstudio-config"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "webstudio" })
  }
  data = {
    PORT                   = "3000"
    NODE_ENV               = "production"
    DEPLOYMENT_ENVIRONMENT = "production"
    DEPLOYMENT_URL         = "https://${var.webstudio_domain}"
    POSTGREST_URL          = "http://webstudio-postgrest:3000"
    MAX_ASSETS_PER_PROJECT = "50"
    PUBLISHER_HOST         = var.webstudio_publisher_host
  }
}

resource "kubernetes_deployment_v1" "webstudio_builder" {
  metadata {
    name      = "webstudio-builder"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "webstudio", component = "builder" })
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "webstudio", component = "builder" } }
    template {
      metadata { labels = merge(local.common_labels, { app = "webstudio", component = "builder" }) }
      spec {
        node_selector = local.node_selector
        image_pull_secrets { name = "ops-registry-secret" }

        init_container {
          name  = "generate-jwt"
          image = "node:22-alpine"
          command = ["node", "-e", <<-JS
            const crypto = require('crypto');
            const fs = require('fs');
            const secret = fs.readFileSync('/secrets/WEBSTUDIO_POSTGREST_JWT_SECRET', 'utf8').trim();
            const header = Buffer.from(JSON.stringify({alg:'HS256',typ:'JWT'})).toString('base64url');
            const payload = Buffer.from(JSON.stringify({role:'anon',iss:'webstudio',iat:Math.floor(Date.now()/1000),exp:Math.floor(Date.now()/1000)+315360000})).toString('base64url');
            const sig = crypto.createHmac('sha256',secret).update(header+'.'+payload).digest('base64url');
            fs.writeFileSync('/jwt/token', header+'.'+payload+'.'+sig);
          JS
          ]
          volume_mount {
            name       = "jwt-volume"
            mount_path = "/jwt"
          }
          volume_mount {
            name       = "secret-files"
            mount_path = "/secrets"
            read_only  = true
          }
        }

        container {
          name              = "builder"
          image             = var.webstudio_builder_image
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 3000
            name           = "http"
          }
          env_from {
            config_map_ref { name = kubernetes_config_map_v1.webstudio_config.metadata[0].name }
          }
          env {
            name = "WEBSTUDIO_DB_USER"
            value_from {
              secret_key_ref {
                name = "webstudio-secrets"
                key  = "WEBSTUDIO_DB_USER"
              }
            }
          }
          env {
            name = "DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = "webstudio-secrets"
                key  = "WEBSTUDIO_DB_PASSWORD"
              }
            }
          }
          env {
            name  = "DATABASE_URL"
            value = "postgresql://$(WEBSTUDIO_DB_USER):$(DATABASE_PASSWORD)@${local.webstudio_pg}"
          }
          env {
            name  = "DIRECT_URL"
            value = "postgresql://$(WEBSTUDIO_DB_USER):$(DATABASE_PASSWORD)@${local.webstudio_pg}"
          }
          env {
            name  = "POSTGREST_API_KEY"
            value = "file:/jwt/token"
          }
          dynamic "env" {
            for_each = {
              AUTH_SECRET          = "WEBSTUDIO_AUTH_SECRET"
              GOOGLE_CLIENT_ID     = "WEBSTUDIO_GOOGLE_CLIENT_ID"
              GOOGLE_CLIENT_SECRET = "WEBSTUDIO_GOOGLE_CLIENT_SECRET"
              DEV_LOGIN            = "WEBSTUDIO_DEV_LOGIN"
            }
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name     = "webstudio-secrets"
                  key      = env.value
                  optional = true
                }
              }
            }
          }
          resources {
            requests = { cpu = "250m", memory = "512Mi" }
            limits   = { cpu = "1000m", memory = "1Gi" }
          }
          volume_mount {
            name       = "jwt-volume"
            mount_path = "/jwt"
            read_only  = true
          }
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
          liveness_probe {
            http_get {
              path = "/healthz"
              port = 3000
            }
            initial_delay_seconds = 10
            period_seconds        = 15
            timeout_seconds       = 5
          }
          readiness_probe {
            http_get {
              path = "/healthz"
              port = 3000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 5
          }
          startup_probe {
            http_get {
              path = "/healthz"
              port = 3000
            }
            period_seconds    = 5
            failure_threshold = 30
          }
        }

        volume {
          name = "jwt-volume"
          empty_dir {}
        }
        volume {
          name = "secret-files"
          secret {
            secret_name = "webstudio-secrets"
            items {
              key  = "WEBSTUDIO_POSTGREST_JWT_SECRET"
              path = "WEBSTUDIO_POSTGREST_JWT_SECRET"
            }
          }
        }
        volume {
          name = "tmp"
          empty_dir {}
        }
      }
    }
  }
  depends_on = [
    kubectl_manifest.infisical_app,
    kubectl_manifest.infisical_ops_pull,
  ]
}

resource "kubernetes_deployment_v1" "webstudio_postgrest" {
  metadata {
    name      = "webstudio-postgrest"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "webstudio", component = "postgrest" })
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "webstudio", component = "postgrest" } }
    template {
      metadata { labels = merge(local.common_labels, { app = "webstudio", component = "postgrest" }) }
      spec {
        node_selector = local.node_selector
        image_pull_secrets { name = "ops-registry-secret" }
        container {
          name              = "postgrest"
          image             = var.webstudio_postgrest_image
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 3000
            name           = "http"
          }
          env {
            name = "WEBSTUDIO_DB_USER"
            value_from {
              secret_key_ref {
                name = "webstudio-secrets"
                key  = "WEBSTUDIO_DB_USER"
              }
            }
          }
          env {
            name = "WEBSTUDIO_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "webstudio-secrets"
                key  = "WEBSTUDIO_DB_PASSWORD"
              }
            }
          }
          env {
            name  = "PGRST_DB_URI"
            value = "postgresql://$(WEBSTUDIO_DB_USER):$(WEBSTUDIO_DB_PASSWORD)@${local.webstudio_pg}"
          }
          env {
            name  = "PGRST_DB_SCHEMAS"
            value = "public"
          }
          env {
            name  = "PGRST_DB_ANON_ROLE"
            value = "anon"
          }
          env {
            name  = "PGRST_DB_USE_LEGACY_GUCS"
            value = "false"
          }
          env {
            name = "PGRST_JWT_SECRET"
            value_from {
              secret_key_ref {
                name = "webstudio-secrets"
                key  = "WEBSTUDIO_POSTGREST_JWT_SECRET"
              }
            }
          }
          resources {
            requests = { cpu = "200m", memory = "512Mi" }
            limits   = { cpu = "1000m", memory = "2Gi" }
          }
          liveness_probe {
            tcp_socket { port = 3000 }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          readiness_probe {
            tcp_socket { port = 3000 }
            initial_delay_seconds = 3
            period_seconds        = 5
          }
        }
      }
    }
  }
  depends_on = [kubectl_manifest.infisical_app]
}

resource "kubernetes_service_v1" "webstudio_builder" {
  metadata {
    name      = "webstudio-builder"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "webstudio", component = "builder" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "webstudio", component = "builder" }
    port {
      port        = 3000
      target_port = 3000
    }
  }
}

resource "kubernetes_service_v1" "webstudio_postgrest" {
  metadata {
    name      = "webstudio-postgrest"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "webstudio", component = "postgrest" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "webstudio", component = "postgrest" }
    port {
      port        = 3000
      target_port = 3000
    }
  }
}

resource "kubernetes_ingress_v1" "webstudio" {
  metadata {
    name      = "webstudio-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "webstudio" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "100m"
      "nginx.ingress.kubernetes.io/proxy-http-version" = "1.1"
      "nginx.ingress.kubernetes.io/enable-websocket"   = "true"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.webstudio_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.webstudio_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.webstudio_builder.metadata[0].name
              port { number = 3000 }
            }
          }
        }
      }
    }
  }
}
