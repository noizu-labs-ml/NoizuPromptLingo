variable "kube_config_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "noizu"
}

variable "namespace" {
  description = "CRM-tier namespace (created by this module)."
  type        = string
  default     = "platform-crm"
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

variable "postgres_host" {
  description = "Shared Postgres/TimescaleDB service DNS (platform/init)."
  type        = string
  default     = "platform-timescaledb.platform.svc.cluster.local"
}

# --- espocrm ---------------------------------------------------------------
variable "espocrm_image" {
  type    = string
  default = "espocrm/espocrm:latest"
}

variable "espocrm_domain" {
  type    = string
  default = "espocrm.noizu.com"
}

variable "espocrm_db_name" {
  type    = string
  default = "espocrm"
}

variable "espocrm_db_user" {
  type    = string
  default = "espocrm"
}

variable "espocrm_storage" {
  type    = string
  default = "10Gi"
}

# --- bottlecrm -------------------------------------------------------------
variable "bottlecrm_image" {
  type    = string
  default = "ops.noizu.com/bottlecrm:latest"
}

variable "bottlecrm_frontend_image" {
  type    = string
  default = "ops.noizu.com/bottlecrm-frontend:latest"
}

variable "bottlecrm_domain" {
  type    = string
  default = "bottlecrm.noizu.com"
}

variable "bottlecrm_db_name" {
  type    = string
  default = "bottlecrm"
}

variable "bottlecrm_db_user" {
  type    = string
  default = "bottlecrm"
}

variable "bottlecrm_default_from_email" {
  type    = string
  default = "noreply@therobotlives.com"
}

variable "bottlecrm_admin_email" {
  type    = string
  default = "admin@noizu.com"
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

variable "infisical_secrets_path" {
  type    = string
  default = "/crm"
}

variable "managed_secret_name" {
  type    = string
  default = "crm-app-secrets"
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
