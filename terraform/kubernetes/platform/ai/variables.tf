variable "kube_config_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "noizu"
}

variable "namespace" {
  description = "Platform-AI tier namespace (created by this module)."
  type        = string
  default     = "platform-ai"
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

# --- Text-to-speech services ----------------------------------------------
variable "chatterbox_image" {
  description = "Chatterbox TTS image (OpenAI-compatible GPU TTS API)."
  type        = string
  default     = "travisvn/chatterbox-tts-api:latest"
}

variable "kitten_image" {
  description = "Kitten TTS image (lightweight CPU TTS)."
  type        = string
  # ops.noizu.com/kitten-tts was never pushed to the registry; this is the
  # upstream community image it mirrors (KittenTTS CPU server, port 8005).
  default = "onehandcoding/kitten-tts-cpu:latest"
}

variable "infisical_host_api" {
  type    = string
  default = "https://infisical.noizu.com/api"
}
