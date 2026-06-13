# ---------------------------------------------------------------------------
# Routing Policies
# ---------------------------------------------------------------------------

locals {
  # v0.104.0 route policies use channel NAMES, not IDs
  active_channel_names = compact([
    var.channels_enabled ? "noizu-monitor-email-me" : "",
    var.channels_enabled && var.slack_webhook_url != "" ? "noizu-monitor-slack" : "",
    var.channels_enabled && var.ops_webhook_url != "" ? "noizu-monitor-ops-webhook" : "",
  ])
}

resource "signoz_route_policy" "critical_production" {
  count = var.routing_enabled && var.channels_enabled ? 1 : 0

  route_name  = "noizu-monitor-critical-production"
  description = "Route critical production alerts to all critical channels"
  enabled     = true

  matchers = [
    { match_name = "severity", match_value = "critical", match_type = "equals" },
    { match_name = "environment", match_value = "production", match_type = "equals" },
  ]

  channel_ids = local.active_channel_names

  group_wait      = "30s"
  group_interval  = "5m"
  repeat_interval = "4h"
}

resource "signoz_route_policy" "warning_production" {
  count = var.routing_enabled && var.channels_enabled ? 1 : 0

  route_name  = "noizu-monitor-warning-production"
  description = "Route warning production alerts to warning channels"
  enabled     = true

  matchers = [
    { match_name = "severity", match_value = "warning", match_type = "equals" },
    { match_name = "environment", match_value = "production", match_type = "equals" },
  ]

  channel_ids = local.active_channel_names

  group_wait      = "30s"
  group_interval  = "5m"
  repeat_interval = "1h"
}

resource "signoz_route_policy" "observability" {
  count = var.routing_enabled && var.channels_enabled ? 1 : 0

  route_name        = "noizu-monitor-observability"
  description       = "Route infra observability alerts to warning channels"
  enabled           = true
  continue_matching = true

  matchers = [
    { match_name = "service", match_value = "infra-.*", match_type = "regex" },
    { match_name = "environment", match_value = "production", match_type = "equals" },
  ]

  channel_ids = local.active_channel_names

  group_wait      = "30s"
  group_interval  = "5m"
  repeat_interval = "1h"
}
