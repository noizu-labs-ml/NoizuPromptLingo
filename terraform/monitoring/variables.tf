# ---------------------------------------------------------------------------
# Provider
# ---------------------------------------------------------------------------

variable "signoz_endpoint" {
  description = "SigNoz query service URL"
  type        = string
  default     = "https://apm.noizu.com"
}

variable "signoz_access_token" {
  description = "SigNoz API access token (Settings > API Keys)"
  type        = string
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Feature Gates
# ---------------------------------------------------------------------------

variable "alerts_enabled" {
  description = "Enable alert rule evaluation (set true after channels verified)"
  type        = bool
  default     = false
}

variable "channels_enabled" {
  description = "Create notification channels in SigNoz"
  type        = bool
  default     = false
}

variable "routing_enabled" {
  description = "Create routing policies in SigNoz"
  type        = bool
  default     = false
}

variable "dashboards_enabled" {
  description = "Create dashboards in SigNoz"
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Notification Targets
# ---------------------------------------------------------------------------

variable "alert_owner_email" {
  description = "Primary alert recipient email"
  type        = string
  default     = "keith.brings@noizu.com"
}

variable "slack_alert_channel" {
  description = "Slack channel for alert delivery"
  type        = string
  default     = "#noizu-alerts"
}

variable "slack_webhook_url" {
  description = "Slack incoming webhook URL"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ops_webhook_url" {
  description = "Generic operations webhook URL (e.g. n8n, PagerDuty)"
  type        = string
  sensitive   = true
  default     = ""
}

# ---------------------------------------------------------------------------
# Channel Routing Preferences
# ---------------------------------------------------------------------------

variable "warning_preferred_channels" {
  description = "Channel keys for warning-severity alerts"
  type        = list(string)
  default     = ["email_me", "slack_ops"]
}

variable "critical_preferred_channels" {
  description = "Channel keys for critical-severity alerts"
  type        = list(string)
  default     = ["email_me", "slack_ops"]
}

# ---------------------------------------------------------------------------
# Data Retention
# ---------------------------------------------------------------------------

variable "metrics_retention_days" {
  description = "Days to retain metrics in ClickHouse"
  type        = number
  default     = 30
}

variable "logs_retention_days" {
  description = "Days to retain logs in ClickHouse"
  type        = number
  default     = 15
}

variable "traces_retention_days" {
  description = "Days to retain traces in ClickHouse"
  type        = number
  default     = 15
}
