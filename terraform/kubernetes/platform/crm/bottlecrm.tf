# ---------------------------------------------------------------------------
# BottleCRM — Django REST backend + celery-worker + celery-beat + SvelteKit
# frontend, all in one pod (mirrors the legacy chart). Served at
# bottlecrm.noizu.com. Postgres + Valkey from platform/init; SMTP via SendGrid.
# ---------------------------------------------------------------------------
locals {
  # Shared env across the Django backend, celery worker/beat, and the migrate
  # init container.
  bottlecrm_env = {
    DBNAME             = var.bottlecrm_db_name
    DBUSER             = var.bottlecrm_db_user
    DBHOST             = var.postgres_host
    DBPORT             = "5432"
    ENV_TYPE           = "prod"
    DEBUG              = "False"
    ALLOWED_HOSTS      = "${var.bottlecrm_domain},bottlecrm,localhost,*"
    DOMAIN_NAME        = "https://${var.bottlecrm_domain}"
    FRONTEND_URL       = "https://${var.bottlecrm_domain}"
    DEFAULT_FROM_EMAIL = var.bottlecrm_default_from_email
    ADMIN_EMAIL        = var.bottlecrm_admin_email
    EMAIL_HOST         = "smtp.sendgrid.net"
    EMAIL_PORT         = "587"
    EMAIL_USE_TLS      = "True"
    EMAIL_HOST_USER    = "apikey"
  }

  # name -> key in crm-app-secrets. Redis URL carries the Valkey password.
  bottlecrm_secret_env = {
    SECRET_KEY            = "BOTTLECRM_SECRET_KEY"
    DBPASSWORD            = "BOTTLECRM_DB_PASSWORD"
    GOOGLE_CLIENT_ID      = "BOTTLECRM_GOOGLE_CLIENT_ID"
    GOOGLE_CLIENT_SECRET  = "BOTTLECRM_GOOGLE_CLIENT_SECRET"
    EMAIL_HOST_PASSWORD   = "SENDGRID_API_KEY"
    CELERY_BROKER_URL     = "BOTTLECRM_REDIS_URL"
    CELERY_RESULT_BACKEND = "BOTTLECRM_REDIS_URL"
  }
}

resource "kubernetes_deployment_v1" "bottlecrm" {
  metadata {
    name      = "bottlecrm"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "bottlecrm" })
  }
  spec {
    replicas = 1
    strategy { type = "Recreate" }
    selector {
      match_labels = { app = "bottlecrm" }
    }
    template {
      metadata {
        labels = merge(local.common_labels, { app = "bottlecrm" })
      }
      spec {
        node_selector = local.node_selector
        image_pull_secrets {
          name = "ops-registry-secret"
        }

        init_container {
          name    = "db-wait"
          image   = "postgres:16-alpine"
          command = ["sh", "-c", "until pg_isready -h ${var.postgres_host} -p 5432 -U ${var.bottlecrm_db_user}; do echo 'waiting for postgres...'; sleep 3; done"]
        }
        init_container {
          name              = "migrate"
          image             = var.bottlecrm_image
          image_pull_policy = "Always"
          command           = ["sh", "-c", "python manage.py migrate --noinput && python manage.py collectstatic --noinput"]
          dynamic "env" {
            for_each = local.bottlecrm_env
            content {
              name  = env.key
              value = env.value
            }
          }
          dynamic "env" {
            for_each = local.bottlecrm_secret_env
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
          volume_mount {
            name       = "static"
            mount_path = "/app/staticfiles"
          }
        }

        container {
          name              = "backend"
          image             = var.bottlecrm_image
          image_pull_policy = "Always"
          command           = ["gunicorn", "crm.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3", "--timeout", "120"]
          port {
            container_port = 8000
            protocol       = "TCP"
          }
          dynamic "env" {
            for_each = local.bottlecrm_env
            content {
              name  = env.key
              value = env.value
            }
          }
          dynamic "env" {
            for_each = local.bottlecrm_secret_env
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
          volume_mount {
            name       = "static"
            mount_path = "/app/staticfiles"
          }
          resources {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "1000m", memory = "1Gi" }
          }
          liveness_probe {
            http_get {
              path = "/admin/login/"
              port = 8000
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/admin/login/"
              port = 8000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }

        container {
          name              = "celery-worker"
          image             = var.bottlecrm_image
          image_pull_policy = "Always"
          command           = ["celery", "-A", "crm", "worker", "--loglevel=info", "--concurrency=2"]
          dynamic "env" {
            for_each = local.bottlecrm_env
            content {
              name  = env.key
              value = env.value
            }
          }
          dynamic "env" {
            for_each = local.bottlecrm_secret_env
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
            requests = { cpu = "50m", memory = "128Mi" }
            limits   = { cpu = "500m", memory = "512Mi" }
          }
        }

        container {
          name              = "celery-beat"
          image             = var.bottlecrm_image
          image_pull_policy = "Always"
          command           = ["celery", "-A", "crm", "beat", "--loglevel=info"]
          dynamic "env" {
            for_each = local.bottlecrm_env
            content {
              name  = env.key
              value = env.value
            }
          }
          dynamic "env" {
            for_each = local.bottlecrm_secret_env
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
            requests = { cpu = "25m", memory = "64Mi" }
            limits   = { cpu = "250m", memory = "256Mi" }
          }
        }

        container {
          name              = "frontend"
          image             = var.bottlecrm_frontend_image
          image_pull_policy = "Always"
          port {
            container_port = 3000
            protocol       = "TCP"
          }
          env {
            name  = "PORT"
            value = "3000"
          }
          env {
            name  = "ORIGIN"
            value = "https://${var.bottlecrm_domain}"
          }
          env {
            name  = "GOOGLE_LOGIN_DOMAIN"
            value = "https://${var.bottlecrm_domain}"
          }
          env {
            name  = "PUBLIC_DJANGO_API_URL"
            value = "https://${var.bottlecrm_domain}"
          }
          env {
            name  = "DJANGO_API_URL"
            value = "http://localhost:8000"
          }
          env {
            name  = "NODE_ENV"
            value = "production"
          }
          env {
            name = "GOOGLE_CLIENT_ID"
            value_from {
              secret_key_ref {
                name = var.managed_secret_name
                key  = "BOTTLECRM_GOOGLE_CLIENT_ID"
              }
            }
          }
          resources {
            requests = { cpu = "50m", memory = "64Mi" }
            limits   = { cpu = "500m", memory = "256Mi" }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 10
            period_seconds        = 30
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }

        volume {
          name = "static"
          empty_dir {}
        }
      }
    }
  }

  depends_on = [
    kubectl_manifest.infisical_app_secrets,
    kubectl_manifest.infisical_ops_pull,
  ]
}

resource "kubernetes_service_v1" "bottlecrm" {
  metadata {
    name      = "bottlecrm"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "bottlecrm" })
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "bottlecrm" }
    port {
      name        = "backend"
      port        = 8000
      target_port = 8000
      protocol    = "TCP"
    }
    port {
      name        = "frontend"
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "bottlecrm" {
  metadata {
    name      = "bottlecrm-ingress"
    namespace = local.ns
    labels    = merge(local.common_labels, { app = "bottlecrm" })
    annotations = merge(local.cf_annotations, {
      "nginx.ingress.kubernetes.io/proxy-body-size"      = "10m"
      "nginx.ingress.kubernetes.io/proxy-buffer-size"    = "16k"
      "nginx.ingress.kubernetes.io/proxy-buffers-number" = "4"
    })
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.bottlecrm_domain]
      secret_name = var.tls_secret_name
    }
    rule {
      host = var.bottlecrm_domain
      http {
        # Django API + admin -> backend (8000)
        path {
          path      = "/api"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.bottlecrm.metadata[0].name
              port { number = 8000 }
            }
          }
        }
        path {
          path      = "/admin"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.bottlecrm.metadata[0].name
              port { number = 8000 }
            }
          }
        }
        # SvelteKit frontend (3000) catches everything else
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.bottlecrm.metadata[0].name
              port { number = 3000 }
            }
          }
        }
      }
    }
  }
}
