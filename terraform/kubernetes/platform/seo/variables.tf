variable "kube_config_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "noizu"
}

variable "namespace" {
  description = "SEO-tier namespace (created by this module)."
  type        = string
  default     = "platform-seo"
}

variable "storage_class" {
  description = "Fallback StorageClass if the root init state isn't readable."
  type        = string
  default     = "longhorn"
}

variable "node_selector" {
  description = "nodeSelector fallback if the root init state isn't readable."
  type        = map(string)
  default     = { "kubernetes.io/hostname" = "noizu-server" }
}

variable "init_state_path" {
  description = "Absolute path to the root init module's local tfstate (set by Terragrunt). Empty falls back to the in-tree relative path."
  type        = string
  default     = ""
}

# --- Shared data tier (platform/init) --------------------------------------
variable "mariadb_host" {
  description = "Shared MariaDB service DNS (platform/init)."
  type        = string
  default     = "platform-mariadb.platform.svc.cluster.local"
}

# --- seonaut ---------------------------------------------------------------
variable "seonaut_image" {
  type    = string
  default = "ops.noizu.com/seonaut:latest"
}

variable "seonaut_domain" {
  type    = string
  default = "seonaut.noizu.com"
}

variable "seonaut_db_name" {
  type    = string
  default = "seonaut"
}

variable "seonaut_db_user" {
  type    = string
  default = "seonaut"
}

# --- serpbear --------------------------------------------------------------
variable "serpbear_image" {
  type    = string
  default = "towfiqi/serpbear:latest"
}

variable "serpbear_domain" {
  type    = string
  default = "serpbear.noizu.com"
}

variable "serpbear_storage" {
  type    = string
  default = "5Gi"
}

# --- Infisical operator config (shared across this tier's workloads) --------
variable "infisical_project_slug" {
  type    = string
  default = "k8-infra"
}

variable "infisical_env_slug" {
  type    = string
  default = "prod"
}

variable "infisical_credentials_secret" {
  description = "Universal-auth machine-identity credentials secret."
  type        = string
  default     = "universal-auth-credentials"
}

variable "infisical_credentials_namespace" {
  type    = string
  default = "infra"
}

variable "infisical_resync_interval" {
  type    = number
  default = 120
}

# Infisical path holding the SEO app secrets, and the managed Secret the operator
# creates from it.
variable "infisical_secrets_path" {
  type    = string
  default = "/seo"
}

variable "managed_secret_name" {
  type    = string
  default = "seo-app-secrets"
}

# Shared wildcard TLS secret synced from Infisical (/shared/tls).
variable "tls_secret_name" {
  type    = string
  default = "cloudflare-tls-synced"
}

# Shared ops.noizu.com registry pull credentials (/shared/registry).
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
