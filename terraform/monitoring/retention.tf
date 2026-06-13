# ---------------------------------------------------------------------------
# Data Retention
# ---------------------------------------------------------------------------
# v0.104.0 only supports custom retention for logs via API.
# Metrics (30d) and traces (15d) use server defaults.

resource "signoz_data_retention" "main" {
  metrics_ttl_duration_hrs      = 720
  metrics_move_ttl_duration_hrs = 0
  logs_ttl_duration_hrs         = var.logs_retention_days * 24
  logs_move_ttl_duration_hrs    = 0
  traces_ttl_duration_hrs       = 360
  traces_move_ttl_duration_hrs  = 0
}
