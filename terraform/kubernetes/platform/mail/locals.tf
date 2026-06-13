locals {
  ns            = kubernetes_namespace_v1.mail.metadata[0].name
  storage_class = try(data.terraform_remote_state.init.outputs.storage_class, var.storage_class)

  # Labels mirror the chart's "mailu.labels" helper.
  common_labels = {
    "app.kubernetes.io/name"       = "mailu"
    "app.kubernetes.io/managed-by" = "terraform"
    "app.kubernetes.io/part-of"    = "noizu-infra"
  }

  # Per-component metadata labels (chart used a bare `app:` label for selectors).
  labels = { for app in [
    "postgresql", "redis", "admin", "front", "postfix",
    "dovecot", "rspamd", "roundcube", "mta-sts", "mailu-dkim",
  ] : app => merge(local.common_labels, { app = app }) }

  infisical_base = {
    resync_interval       = var.infisical_resync_interval
    credentials_secret    = var.infisical_credentials_secret
    credentials_namespace = var.infisical_credentials_namespace
    project_slug          = var.infisical_project_slug
    env_slug              = var.infisical_env_slug
  }

  # Managed Secret (synced by Infisical) consumed by all Mailu workloads.
  app_secret_name = "mail-app-secrets"

  # Infisical secrets paths.
  app_secrets_path    = "/mail/mailu"
  cf_tls_secrets_path = "/apps/tls/therobotlives"

  # Managed secret names.
  ops_pull_secret = "ops-registry-secret"
  cf_tls_secret   = "cloudflare-tls-therobotlives"
  le_tls_secret   = "mail-tls-letsencrypt"

  image_pull_secrets = [local.ops_pull_secret]

  images = {
    front      = "ghcr.io/mailu/nginx:2024.06"
    admin      = "ghcr.io/mailu/admin:2024.06"
    postfix    = "ghcr.io/mailu/postfix:2024.06"
    dovecot    = "ghcr.io/mailu/dovecot:2024.06"
    rspamd     = "ghcr.io/mailu/rspamd:2024.06"
    roundcube  = "ghcr.io/mailu/webmail:2024.06"
    postgresql = "ops.noizu.com/timescaledb:latest-pg17"
    redis      = "redis:7-alpine"
  }

  # ---- Shared Mailu env (from "mailu.mailu-common-env" helper) --------------
  common_env_values = {
    MAILU_HELM_CHART   = "true"
    KUBERNETES_INGRESS = "true"
    DOMAIN             = var.domain
    HOSTNAMES          = var.hostnames
    SUBNET             = var.subnet
    REDIS_ADDRESS      = "redis:6379"
  }

  common_env_secrets = {
    SECRET_KEY     = "MAILU_SECRET_KEY"
    REDIS_PASSWORD = "REDIS_PASSWORD"
  }

  # ---- Service-discovery env (from "mailu.mailu-service-env" helper) --------
  service_env_values = {
    ADMIN_ADDRESS    = "admin.${local.ns}.svc.cluster.local"
    FRONT_ADDRESS    = "front.${local.ns}.svc.cluster.local"
    SMTP_ADDRESS     = "postfix.${local.ns}.svc.cluster.local"
    IMAP_ADDRESS     = "dovecot.${local.ns}.svc.cluster.local"
    ANTISPAM_ADDRESS = "rspamd.${local.ns}.svc.cluster.local"
    WEBMAIL_ADDRESS  = "roundcube.${local.ns}.svc.cluster.local"
  }
}
