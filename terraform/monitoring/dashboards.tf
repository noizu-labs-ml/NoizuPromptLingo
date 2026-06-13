# ---------------------------------------------------------------------------
# Dashboards
# ---------------------------------------------------------------------------

locals {
  dashboards = {
    cluster_overview = {
      title = "noizu – Cluster Overview"
      name  = "cluster-overview"
      desc  = "Node resources, pod health, restarts, and disk pressure across all namespaces"
      tags  = ["infra", "cluster"]
    }
    data_tier = {
      title = "noizu – Data Tier"
      name  = "data-tier"
      desc  = "Postgres, MySQL, Redis, Valkey, and ClickHouse health metrics"
      tags  = ["data", "databases"]
    }
    app_services = {
      title = "noizu – Application Services"
      name  = "app-services"
      desc  = "HTTP request rate, error rate, and latency across application services"
      tags  = ["apps", "http"]
    }
    ai_infra = {
      title = "noizu – AI/ML Infrastructure"
      name  = "ai-infra"
      desc  = "vLLM GPU utilization, Weaviate queries, and Open-WebUI health"
      tags  = ["ai", "gpu"]
    }
    log_volume = {
      title = "noizu – Log Volume"
      name  = "log-volume"
      desc  = "Log ingestion rates, error ratios, and top producers for cost awareness"
      tags  = ["logs", "costs"]
    }
    otel_health = {
      title = "noizu – OTEL Collector Health"
      name  = "otel-health"
      desc  = "Collector pipeline throughput, export failures, queue depth, and drops"
      tags  = ["observability", "otel"]
    }
  }

  dashboard_data = {
    for k, v in local.dashboards :
    k => jsondecode(file("${path.module}/dashboards/${v.name}.json"))
  }
}

resource "signoz_dashboard" "this" {
  for_each = var.dashboards_enabled ? local.dashboards : {}

  title       = each.value.title
  name        = each.value.name
  description = each.value.desc
  tags        = each.value.tags
  version     = "v4"

  collapsable_rows_migrated = true
  uploaded_grafana          = false

  layout    = jsonencode(local.dashboard_data[each.key].layout)
  widgets   = jsonencode(local.dashboard_data[each.key].widgets)
  variables = jsonencode(local.dashboard_data[each.key].variables)
}
