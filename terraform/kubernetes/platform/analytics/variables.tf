variable "kube_config_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "noizu"
}

variable "namespace" {
  description = "Analytics-tier namespace (created by this module)."
  type        = string
  default     = "platform-analytics"
}

variable "storage_class" {
  type    = string
  default = "longhorn"
}

variable "node_selector" {
  type    = map(string)
  default = { "kubernetes.io/hostname" = "noizu-server" }
}

variable "init_state_path" {
  type    = string
  default = ""
}

# --- Shared data tier (platform/init) --------------------------------------
variable "mariadb_host" {
  type    = string
  default = "platform-mariadb.platform.svc.cluster.local"
}

# --- matomo ----------------------------------------------------------------
variable "matomo_image" {
  type    = string
  default = "matomo:5-apache"
}

variable "matomo_domain" {
  type    = string
  default = "matomo.noizu.com"
}

variable "matomo_db_name" {
  type    = string
  default = "matomo"
}

variable "matomo_db_user" {
  type    = string
  default = "matomo"
}

variable "matomo_storage" {
  type    = string
  default = "10Gi"
}

# --- growthbook ------------------------------------------------------------
variable "growthbook_image" {
  type    = string
  default = "growthbook/growthbook:latest"
}

variable "growthbook_domain" {
  type    = string
  default = "growthbook.noizu.com"
}

# --- Infisical operator config ---------------------------------------------
variable "infisical_project_slug" {
  type    = string
  default = "k8-infra"
}

variable "infisical_env_slug" {
  type    = string
  default = "prod"
}

variable "infisical_credentials_secret" {
  type    = string
  default = "universal-auth-credentials"
}

variable "infisical_credentials_namespace" {
  type    = string
  default = "infra"
}

variable "infisical_resync_interval" {
  type    = number
  default = 120
}

variable "infisical_secrets_path" {
  type    = string
  default = "/analytics"
}

variable "managed_secret_name" {
  type    = string
  default = "analytics-app-secrets"
}

variable "tls_secret_name" {
  type    = string
  default = "cloudflare-tls-synced"
}

variable "registry_secrets_path" {
  type    = string
  default = "/shared/registry"
}

# Self-hosted Infisical API. Without this the operator defaults to Infisical
# Cloud (app.infisical.com) and every InfisicalSecret 401s, so cloudflare-tls-synced
# never syncs and ingresses fall back to nginx's self-signed Fake Certificate.
variable "infisical_host_api" {
  type    = string
  default = "https://infisical.noizu.com/api"
}
