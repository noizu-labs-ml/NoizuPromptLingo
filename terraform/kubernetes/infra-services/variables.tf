variable "kube_config_path" {
  description = "Path to the kubeconfig file."
  type        = string
}

variable "kube_context" {
  description = "kubeconfig context for the target cluster."
  type        = string
}

variable "namespace" {
  description = "Namespace for platform services (created by init; fallback if init state unreadable)."
  type        = string
  default     = "infra"
}

variable "storage_class" {
  description = "StorageClass for persistent volumes (fallback if init state unreadable)."
  type        = string
  default     = "longhorn"
}

variable "node_selector" {
  description = "nodeSelector pinning workloads to the base node (fallback if init state isn't readable)."
  type        = map(string)
  default     = { "kubernetes.io/hostname" = "noizu-server" }
}

variable "init_state_path" {
  description = "Absolute path to init's local tfstate. Set by Terragrunt (Terraform runs from a cache dir); empty falls back to the in-tree relative path for plain `terraform`."
  type        = string
  default     = ""
}

# --- ArgoCD ----------------------------------------------------------------
variable "argocd_chart_version" {
  description = "argo-cd helm chart version."
  type        = string
  default     = "9.4.9"
}

variable "argocd_domain" {
  type    = string
  default = "argocd.noizu.com"
}

# --- Keygen (proxy mode) ---------------------------------------------------
variable "keygen_proxy_image" {
  type    = string
  default = "nginx:1.27-alpine"
}

variable "keygen_domains" {
  type    = list(string)
  default = ["keygen.noizu.com", "keygen.derobot.is"]
}

# --- Health tests ----------------------------------------------------------
variable "health_tests_enabled" {
  description = "Create the one-shot health-test Job."
  type        = bool
  default     = false
}

variable "health_tests_image" {
  type    = string
  default = "curlimages/curl:8.11.0"
}
