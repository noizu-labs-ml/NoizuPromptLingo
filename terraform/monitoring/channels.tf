# ---------------------------------------------------------------------------
# Notification Channels
# ---------------------------------------------------------------------------

locals {
  channel_names = {
    email_me    = "noizu-monitor-email-me"
    slack_ops   = "noizu-monitor-slack"
    ops_webhook = "noizu-monitor-ops-webhook"
  }

  channel_ids = nonsensitive(merge(
    var.channels_enabled ? { email_me = signoz_notification_channel.email_me[0].id } : {},
    var.channels_enabled && var.slack_webhook_url != "" ? { slack_ops = signoz_notification_channel.slack_ops[0].id } : {},
    var.channels_enabled && var.ops_webhook_url != "" ? { ops_webhook = signoz_notification_channel.ops_webhook[0].id } : {},
  ))
}

# --- Email Channel (always created when channels_enabled) ------------------

resource "signoz_notification_channel" "email_me" {
  count = var.channels_enabled ? 1 : 0

  name = "noizu-monitor-email-me"
  type = "email"

  email_configs = {
    to = var.alert_owner_email
  }
}

# --- Slack Channel (requires webhook URL) ----------------------------------

resource "signoz_notification_channel" "slack_ops" {
  count = var.channels_enabled && var.slack_webhook_url != "" ? 1 : 0

  name = "noizu-monitor-slack"
  type = "slack"

  slack_configs = {
    api_url = var.slack_webhook_url
    channel = var.slack_alert_channel
    title   = "[{{ .Status | toUpper }}{{ if eq .Status \"firing\" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.alertname }}"
    text    = "{{ range .Alerts }}*{{ .Labels.alertname }}*\nSeverity: {{ .Labels.severity }}\n{{ .Annotations.description }}\n{{ end }}"
  }
}

# --- Webhook Channel (requires webhook URL) --------------------------------

resource "signoz_notification_channel" "ops_webhook" {
  count = var.channels_enabled && var.ops_webhook_url != "" ? 1 : 0

  name = "noizu-monitor-ops-webhook"
  type = "webhook"

  webhook_configs = {
    api_url = var.ops_webhook_url
  }
}
