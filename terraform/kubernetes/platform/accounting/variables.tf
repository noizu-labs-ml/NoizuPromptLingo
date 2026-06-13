variable "kube_config_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "noizu"
}

variable "namespace" {
  description = "Accounting-tier namespace (created by this module)."
  type        = string
  default     = "platform-accounting"
}

variable "storage_class" {
  description = "Fallback StorageClass if the root init state isn't readable."
  type        = string
  default     = "longhorn"
}

variable "init_state_path" {
  description = "Absolute path to the root init module's local tfstate (set by Terragrunt). Empty falls back to the in-tree relative path."
  type        = string
  default     = ""
}

# Helm release name for the ERPNext subchart. Drives subordinate object names
# (e.g. the service "<release_name>-erpnext" that the ERPNext ingress targets).
variable "release_name" {
  description = "ERPNext helm_release name (matches the original umbrella .Release.Name)."
  type        = string
  default     = "accounting-infra"
}

# --- ERPNext subchart ------------------------------------------------------
variable "erpnext_chart_version" {
  type    = string
  default = "8.0.53"
}

variable "erpnext_image_tag" {
  type    = string
  default = "v16.19.1"
}

variable "erpnext_sites_size" {
  type    = string
  default = "20Gi"
}

variable "erpnext_mariadb_size" {
  type    = string
  default = "10Gi"
}

variable "erpnext_domain" {
  type    = string
  default = "accounting.noizu.com"
}

variable "erpnext_site_name" {
  type    = string
  default = "accounting.noizu.com"
}

# Chart defaults for the ERPNext built-in MariaDB and createSite job. These are
# the upstream chart's literal placeholder values (not Infisical-managed in the
# original chart); override via tfvars for real deployments.
variable "erpnext_mariadb_root_password" {
  type    = string
  default = "changeit"
}

variable "erpnext_admin_password" {
  type    = string
  default = "changeit"
}

# --- Kimai -----------------------------------------------------------------
variable "kimai_image" {
  type    = string
  default = "kimai/kimai2:apache-2.25.0"
}

variable "kimai_storage" {
  type    = string
  default = "5Gi"
}

variable "kimai_domain" {
  type    = string
  default = "kimai.noizu.com"
}

variable "kimai_mariadb_image" {
  type    = string
  default = "ops.noizu.com/mariadb:10.6"
}

variable "kimai_mariadb_storage" {
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

# Infisical path holding the accounting app secrets, and the managed Secret the
# operator creates from it (consumed by Kimai + Kimai MariaDB).
variable "infisical_secrets_path" {
  type    = string
  default = "/accounting"
}

variable "managed_secret_name" {
  type    = string
  default = "accounting-app-secrets"
}

# Shared wildcard TLS secret synced from Infisical (/shared/tls).
variable "tls_secret_name" {
  type    = string
  default = "cloudflare-tls-synced"
}

variable "infisical_host_api" {
  type    = string
  default = "https://infisical.noizu.com/api"
}
