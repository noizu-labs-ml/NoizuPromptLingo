variable "kube_config_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "noizu"
}

variable "namespace" {
  description = "Mail-tier namespace (created by this module)."
  type        = string
  default     = "platform-mail"
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

# --- Infisical operator config -----------------------------------------------
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

# --- Mailu non-secret configuration (mirrors helm values.yaml) ---------------
variable "domain" {
  type    = string
  default = "therobotlives.com"
}

variable "hostnames" {
  type    = string
  default = "mail.therobotlives.com"
}

variable "postmaster" {
  type    = string
  default = "admin"
}

variable "auth_ratelimit_ip" {
  type    = string
  default = "60/hour"
}

variable "message_size_limit" {
  description = "Max message size in bytes (default 50MB)."
  type        = string
  default     = "52428800"
}

variable "subnet" {
  description = "Pod CIDR trusted by Mailu front. VERIFY before deploy: kubectl get nodes -o jsonpath='{.items[0].spec.podCIDR}'"
  type        = string
  default     = "10.1.0.0/24"
}

variable "server_ip" {
  description = "Public IP bound via externalIPs on the front-external Service for mail protocols."
  type        = string
  default     = "208.64.36.80"
}

variable "postgres_user" {
  type    = string
  default = "postgres"
}

# --- Domains -----------------------------------------------------------------
variable "admin_domain" {
  type    = string
  default = "mail-admin.therobotlives.com"
}

variable "roundcube_domain" {
  type    = string
  default = "webmail.therobotlives.com"
}

variable "mta_sts_domain" {
  type    = string
  default = "mta-sts.therobotlives.com"
}

# --- SMTP relay (SendGrid) ---------------------------------------------------
variable "postfix_relay_host" {
  type    = string
  default = "[smtp.sendgrid.net]:587"
}

variable "postfix_relay_username" {
  type    = string
  default = "apikey"
}

variable "infisical_host_api" {
  type    = string
  default = "https://infisical.noizu.com/api"
}
