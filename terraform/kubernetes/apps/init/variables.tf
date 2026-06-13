variable "kube_config_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "noizu"
}

variable "namespace" {
  description = "Apps-tier namespace."
  type        = string
  default     = "apps"
}

variable "storage_class" {
  description = "Fallback StorageClass if the root init state isn't readable."
  type        = string
  default     = "longhorn"
}

variable "init_state_path" {
  description = "Absolute path to the root init module's local tfstate when running through Terragrunt cache. Empty falls back to the in-tree relative path."
  type        = string
  default     = ""
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

variable "infisical_host_api" {
  description = "Self-hosted Infisical API used by the operator. Without this, CRs can default to Infisical Cloud."
  type        = string
  default     = "https://infisical.noizu.com/api"
}

variable "registry_secrets_path" {
  description = "Infisical path holding OPS_REGISTRY_USER / OPS_REGISTRY_PASSWORD for ops.noizu.com pulls."
  type        = string
  default     = "/shared/registry"
}

variable "noizu_site_domain" {
  description = "Public host for the noizu.com website."
  type        = string
  default     = "noizu.com"
}

variable "noizu_site_image" {
  description = "Container image for the noizu.com static website."
  type        = string
  default     = "ops.noizu.com/noizu-website:latest"
}

variable "noizu_site_tls_secret_name" {
  description = "TLS secret name consumed by the noizu.com ingress."
  type        = string
  default     = "noizu-com-tls"
}

variable "noizu_site_chart_path" {
  description = "Absolute path to the noizu.com Helm chart when running through Terragrunt cache. Empty falls back to the in-tree relative path."
  type        = string
  default     = ""
}

variable "aifighter_site_domain" {
  description = "Public host for the aifighter.com website."
  type        = string
  default     = "aifighter.com"
}

variable "aifighter_site_image" {
  description = "Container image for the aifighter.com static website."
  type        = string
  default     = "ops.noizu.com/aifighter.com/web:latest"
}

variable "aifighter_site_tls_secret_name" {
  description = "TLS secret name consumed by the aifighter.com ingress."
  type        = string
  default     = "aifighter-com-tls"
}

variable "aifighter_site_chart_path" {
  description = "Absolute path to the aifighter.com Helm chart when running through Terragrunt cache. Empty falls back to the in-tree relative path."
  type        = string
  default     = ""
}

# --- codefre.sh ---------------------------------------------------------------
variable "codefresh_domain" {
  description = "Public host for the codefre.sh website."
  type        = string
  default     = "codefre.sh"
}

variable "codefresh_backend_image" {
  description = "Container image for the codefre.sh Phoenix backend."
  type        = string
  default     = "ops.noizu.com/codefre.sh/backend:v1.0.6"
}

variable "codefresh_frontend_image" {
  description = "Container image for the codefre.sh Next.js frontend."
  type        = string
  default     = "ops.noizu.com/codefre.sh/frontend:v1.0.6"
}

variable "codefresh_tls_secret_name" {
  description = "TLS secret name consumed by the codefre.sh ingress."
  type        = string
  default     = "codefresh-tls"
}

variable "codefresh_chart_path" {
  description = "Absolute path to the codefre.sh Helm chart when running through Terragrunt cache. Empty falls back to the in-tree relative path."
  type        = string
  default     = ""
}

variable "codefresh_secrets_path" {
  description = "Infisical path holding codefre.sh app secrets."
  type        = string
  default     = "/apps/codefresh"
}

variable "codefresh_managed_secret_name" {
  description = "Name of the Kubernetes Secret synced from Infisical for codefre.sh app credentials."
  type        = string
  default     = "apps-app-secrets"
}

# --- gotta.cc -----------------------------------------------------------------
variable "gottacc_site_domain" {
  description = "Public host for the gotta.cc website."
  type        = string
  default     = "gotta.cc"
}

variable "gottacc_site_image" {
  description = "Container image for the gotta.cc static website."
  type        = string
  default     = "ops.noizu.com/gotta.cc/web:latest"
}

variable "gottacc_site_tls_secret_name" {
  description = "TLS secret name consumed by the gotta.cc ingress."
  type        = string
  default     = "gotta-cc-tls"
}

variable "gottacc_site_chart_path" {
  description = "Absolute path to the gotta.cc Helm chart when running through Terragrunt cache. Empty falls back to the in-tree relative path."
  type        = string
  default     = ""
}

# --- iotgo.io -----------------------------------------------------------------
variable "iotgo_site_domain" {
  description = "Public host for the iotgo.io website."
  type        = string
  default     = "iotgo.io"
}

variable "iotgo_site_image" {
  description = "Container image for the iotgo.io static website."
  type        = string
  default     = "ops.noizu.com/iotgo.io/web:latest"
}

variable "iotgo_site_tls_secret_name" {
  description = "TLS secret name consumed by the iotgo.io ingress."
  type        = string
  default     = "iotgo-tls"
}

variable "iotgo_site_chart_path" {
  description = "Absolute path to the iotgo.io Helm chart when running through Terragrunt cache. Empty falls back to the in-tree relative path."
  type        = string
  default     = ""
}

# --- jailbreakingsite.com -----------------------------------------------------
variable "jailbreakingsite_domain" {
  description = "Public host for the jailbreakingsite.com website."
  type        = string
  default     = "jailbreakingsite.com"
}

variable "jailbreakingsite_image" {
  description = "Container image for the jailbreakingsite.com static website."
  type        = string
  default     = "ops.noizu.com/jailbreakingsite.com/web:latest"
}

variable "jailbreakingsite_tls_secret_name" {
  description = "TLS secret name consumed by the jailbreakingsite.com ingress."
  type        = string
  default     = "jailbreakingsite-com-tls"
}

variable "jailbreakingsite_chart_path" {
  description = "Absolute path to the jailbreakingsite.com Helm chart when running through Terragrunt cache. Empty falls back to the in-tree relative path."
  type        = string
  default     = ""
}

# --- noizurpg.com -------------------------------------------------------------
variable "noizurpg_domain" {
  description = "Public host for the noizurpg.com website."
  type        = string
  default     = "noizurpg.com"
}

variable "noizurpg_image" {
  description = "Container image for the noizurpg.com static website."
  type        = string
  default     = "ops.noizu.com/noizurpg.com/web:latest"
}

variable "noizurpg_tls_secret_name" {
  description = "TLS secret name consumed by the noizurpg.com ingress."
  type        = string
  default     = "noizurpg-com-tls"
}

variable "noizurpg_chart_path" {
  description = "Absolute path to the noizurpg.com Helm chart when running through Terragrunt cache. Empty falls back to the in-tree relative path."
  type        = string
  default     = ""
}

# --- robots-unite.com ---------------------------------------------------------
variable "robotsunite_domain" {
  description = "Public host for the robots-unite.com website."
  type        = string
  default     = "robots-unite.com"
}

variable "robotsunite_image" {
  description = "Container image for the robots-unite.com static website."
  type        = string
  default     = "ops.noizu.com/robots-unite.com/web:latest"
}

variable "robotsunite_tls_secret_name" {
  description = "TLS secret name consumed by the robots-unite.com ingress."
  type        = string
  default     = "robots-unite-com-tls"
}

variable "robotsunite_chart_path" {
  description = "Absolute path to the robots-unite.com Helm chart when running through Terragrunt cache. Empty falls back to the in-tree relative path."
  type        = string
  default     = ""
}

# --- therobotlives.com --------------------------------------------------------
variable "therobotlives_domain" {
  description = "Public host for the therobotlives.com website."
  type        = string
  default     = "therobotlives.com"
}

variable "therobotlives_image" {
  description = "Container image for the therobotlives.com static website."
  type        = string
  default     = "ops.noizu.com/therobotlives.com/web:latest"
}

variable "therobotlives_tls_secret_name" {
  description = "TLS secret name consumed by the therobotlives.com ingress."
  type        = string
  default     = "therobotlives-tls"
}

variable "therobotlives_chart_path" {
  description = "Absolute path to the therobotlives.com Helm chart when running through Terragrunt cache. Empty falls back to the in-tree relative path."
  type        = string
  default     = ""
}

# --- bladeofeternity.com -----------------------------------------------------
variable "bladeofeternity_domain" {
  description = "Public host for the bladeofeternity.com website."
  type        = string
  default     = "bladeofeternity.com"
}

variable "bladeofeternity_image" {
  description = "Container image for the bladeofeternity.com website."
  type        = string
  default     = "ops.noizu.com/bladeofeternity.com/web:latest"
}

variable "bladeofeternity_tls_secret_name" {
  description = "TLS secret name consumed by the bladeofeternity.com ingress."
  type        = string
  default     = "bladeofeternity-tls"
}

variable "bladeofeternity_chart_path" {
  description = "Absolute path to the bladeofeternity.com Helm chart when running through Terragrunt cache. Empty falls back to the in-tree relative path."
  type        = string
  default     = ""
}

# --- therobotknows.com --------------------------------------------------------
variable "therobotknows_domain" {
  description = "Public host for the therobotknows.com website."
  type        = string
  default     = "therobotknows.com"
}

variable "therobotknows_image" {
  description = "Container image for the therobotknows.com static website."
  type        = string
  default     = "ops.noizu.com/therobotknows.com/web:latest"
}

variable "therobotknows_tls_secret_name" {
  description = "TLS secret name consumed by the therobotknows.com ingress."
  type        = string
  default     = "therobotknows-com-tls"
}

variable "therobotknows_chart_path" {
  description = "Absolute path to the therobotknows.com Helm chart when running through Terragrunt cache. Empty falls back to the in-tree relative path."
  type        = string
  default     = ""
}

# --- derobot.is ---------------------------------------------------------------
variable "derobotis_domain" {
  type    = string
  default = "derobot.is"
}

variable "derobotis_image" {
  type    = string
  default = "ops.noizu.com/derobot.is/teaser:latest"
}

variable "derobotis_tls_secret_name" {
  type    = string
  default = "derobotis-tls"
}

variable "derobotis_chart_path" {
  type    = string
  default = ""
}

# --- therobotmakes.com --------------------------------------------------------
variable "therobotmakes_domain" {
  type    = string
  default = "therobotmakes.com"
}

variable "therobotmakes_image" {
  type    = string
  default = "ops.noizu.com/therobotmakes.com/web:latest"
}

variable "therobotmakes_tls_secret_name" {
  type    = string
  default = "therobotmakes-com-tls"
}

variable "therobotmakes_chart_path" {
  type    = string
  default = ""
}

# --- tobornalp.com ------------------------------------------------------------
variable "tobornalp_domain" {
  type    = string
  default = "tobornalp.com"
}

variable "tobornalp_backend_image" {
  type    = string
  default = "ops.noizu.com/tobornalp.com/backend:latest"
}

variable "tobornalp_frontend_image" {
  type    = string
  default = "ops.noizu.com/tobornalp.com/frontend:latest"
}

variable "tobornalp_tls_secret_name" {
  type    = string
  default = "tobornalp-tls"
}

variable "tobornalp_chart_path" {
  type    = string
  default = ""
}

# --- infra.noizu.com ----------------------------------------------------------
variable "infra_portal_image" {
  type    = string
  default = "ops.noizu.com/infra.noizu.com/web:latest"
}

variable "infra_portal_chart_path" {
  type    = string
  default = ""
}
