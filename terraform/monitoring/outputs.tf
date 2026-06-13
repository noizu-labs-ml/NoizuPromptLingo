# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "dashboard_urls" {
  description = "Map of dashboard keys to SigNoz URLs"
  value = {
    for k, d in signoz_dashboard.this : k => "${var.signoz_endpoint}/dashboard/${d.id}"
  }
}

output "notification_channel_names" {
  description = "Map of channel keys to SigNoz channel names"
  value       = local.channel_names
}

output "notification_channel_ids" {
  description = "Map of channel keys to SigNoz channel IDs (only active channels)"
  value       = nonsensitive(local.channel_ids)
}

output "alert_rule_names" {
  description = "List of all managed alert rule names"
  value = concat(
    [for k, v in local.signoz_v2_alerts : v.name],
    [
      signoz_alert.postgres_memory_high.alert,
      signoz_alert.clickhouse_memory_high.alert,
      signoz_alert.mysql_memory_high.alert,
      signoz_alert.redis_memory_high.alert,
      signoz_alert.vllm_gpu_memory.alert,
      signoz_alert.weaviate_memory_high.alert,
      signoz_alert.node_disk_pressure.alert,
      signoz_alert.pod_restart_loop.alert,
      signoz_alert.mailu_dovecot_storage.alert,
      signoz_alert.registry_storage.alert,
    ]
  )
}

output "routing_policy_names" {
  description = "List of active routing policy names"
  value = nonsensitive(compact([
    var.routing_enabled && length(local.channel_ids) > 0 ? signoz_route_policy.critical_production[0].route_name : "",
    var.routing_enabled && length(local.channel_ids) > 0 ? signoz_route_policy.warning_production[0].route_name : "",
    var.routing_enabled && length(local.channel_ids) > 0 ? signoz_route_policy.observability[0].route_name : "",
  ]))
}

output "data_retention" {
  description = "Current data retention settings"
  value = {
    metrics_days = var.metrics_retention_days
    logs_days    = var.logs_retention_days
    traces_days  = var.traces_retention_days
  }
}

output "activation_status" {
  description = "Current activation state of monitoring components"
  value = {
    alerts_enabled   = var.alerts_enabled
    channels_enabled = var.channels_enabled
    routing_enabled  = var.routing_enabled
    endpoint         = var.signoz_endpoint
    alert_count      = length(local.signoz_v2_alerts) + 10
    channel_count    = nonsensitive(length(local.channel_ids))
    routing_count    = nonsensitive(var.routing_enabled && length(local.channel_ids) > 0 ? 3 : 0)
    dashboards_enabled = var.dashboards_enabled
    dashboard_count    = var.dashboards_enabled ? length(local.dashboards) : 0
  }
}
