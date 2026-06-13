variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "name" {
  description = "Human-readable app name shown in the CF dashboard and app launcher"
  type        = string
}

variable "domain" {
  description = "FQDN the app protects (e.g. myapp.noizu.com)"
  type        = string
}

variable "perms" {
  description = "Group keys to include in the team policy: subset of [admin, developer, friend, client]"
  type        = list(string)
}

variable "group_ids" {
  description = "Map of group key -> Cloudflare group ID (admin, developer, friend, client)"
  type        = map(string)
}

variable "service_token_group_id" {
  description = "Cloudflare group ID for service tokens"
  type        = string
}

variable "trusted_ip_group_id" {
  description = "Cloudflare group ID for trusted IP ranges"
  type        = string
}

variable "session_duration" {
  description = "CF Access session duration (e.g. 24h)"
  type        = string
  default     = "24h"
}

variable "app_launcher_visible" {
  description = "Whether the app appears in the CF App Launcher"
  type        = bool
  default     = true
}
