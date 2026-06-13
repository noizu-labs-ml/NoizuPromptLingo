# ---------------------------------------------------------------------------
# Alert Rules — tailored to noizu-infra services
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Locals: V2 log/trace-based alerts
# ---------------------------------------------------------------------------

locals {
  signoz_v2_alerts = {

    # --- Platform-wide --------------------------------------------------

    production_error_logs = {
      name       = "noizu – Production Error Logs"
      alert_type = "LOGS_BASED_ALERT"
      severity   = "critical"
      condition = {
        compositeQuery = {
          queryType = "builder"
          panelType = "graph"
          builderQueries = {
            A = {
              queryName         = "A"
              dataSource        = "logs"
              aggregateOperator = "count"
              filters = {
                items = [
                  {
                    key   = { key = "severity_text", dataType = "string", type = "tag" }
                    op    = "="
                    value = "ERROR"
                  }
                ]
                op = "AND"
              }
            }
          }
        }
        op        = "1"
        target    = 25
        matchType = "4"
      }
      eval_window        = "5m0s"
      frequency          = "1m0s"
      preferred_channels = var.critical_preferred_channels
      labels = {
        environment = "production"
        service     = "noizu-platform"
        tier        = "application"
      }
      description = "More than 25 ERROR-level log entries in 5 minutes across all services."
    }

    # --- Observability (Tier 1) -----------------------------------------

    signoz_export_failures = {
      name       = "noizu – SigNoz/OTEL Export Failures"
      alert_type = "LOGS_BASED_ALERT"
      severity   = "warning"
      condition = {
        compositeQuery = {
          queryType = "builder"
          panelType = "graph"
          builderQueries = {
            A = {
              queryName         = "A"
              dataSource        = "logs"
              aggregateOperator = "count"
              filters = {
                items = [
                  {
                    key   = { key = "body", dataType = "string", type = "tag" }
                    op    = "contains"
                    value = "Exporting failed"
                  }
                ]
                op = "AND"
              }
            }
          }
        }
        op        = "1"
        target    = 3
        matchType = "4"
      }
      eval_window        = "5m0s"
      frequency          = "1m0s"
      preferred_channels = var.warning_preferred_channels
      labels = {
        environment = "production"
        service     = "otel-collector"
        tier        = "observability"
        namespace   = "observability-ns"
      }
      description = "OTEL collector exporter failed 3+ times in 5 minutes — telemetry data loss risk."
    }

    # --- Data Tier (Tier 1) ---------------------------------------------

    clickhouse_errors = {
      name       = "noizu – ClickHouse Errors"
      alert_type = "LOGS_BASED_ALERT"
      severity   = "critical"
      condition = {
        compositeQuery = {
          queryType = "builder"
          panelType = "graph"
          builderQueries = {
            A = {
              queryName         = "A"
              dataSource        = "logs"
              aggregateOperator = "count"
              filters = {
                items = [
                  {
                    key   = { key = "severity_text", dataType = "string", type = "tag" }
                    op    = "="
                    value = "ERROR"
                  },
                  {
                    key   = { key = "k8s.namespace.name", dataType = "string", type = "resource" }
                    op    = "="
                    value = "data-ns"
                  },
                  {
                    key   = { key = "k8s.deployment.name", dataType = "string", type = "resource" }
                    op    = "="
                    value = "shared-clickhouse"
                  }
                ]
                op = "AND"
              }
            }
          }
        }
        op        = "1"
        target    = 5
        matchType = "4"
      }
      eval_window        = "5m0s"
      frequency          = "1m0s"
      preferred_channels = var.critical_preferred_channels
      labels = {
        environment = "production"
        service     = "shared-clickhouse"
        tier        = "data"
        namespace   = "data-ns"
      }
      description = "ClickHouse produced 5+ errors in 5 minutes — SigNoz/PostHog backend at risk."
    }

    postgres_errors = {
      name       = "noizu – Shared Postgres Errors"
      alert_type = "LOGS_BASED_ALERT"
      severity   = "critical"
      condition = {
        compositeQuery = {
          queryType = "builder"
          panelType = "graph"
          builderQueries = {
            A = {
              queryName         = "A"
              dataSource        = "logs"
              aggregateOperator = "count"
              filters = {
                items = [
                  {
                    key   = { key = "severity_text", dataType = "string", type = "tag" }
                    op    = "="
                    value = "ERROR"
                  },
                  {
                    key   = { key = "k8s.namespace.name", dataType = "string", type = "resource" }
                    op    = "="
                    value = "data-ns"
                  },
                  {
                    key   = { key = "k8s.deployment.name", dataType = "string", type = "resource" }
                    op    = "regex"
                    value = "shared-postgres.*"
                  }
                ]
                op = "AND"
              }
            }
          }
        }
        op        = "1"
        target    = 10
        matchType = "4"
      }
      eval_window        = "5m0s"
      frequency          = "1m0s"
      preferred_channels = var.critical_preferred_channels
      labels = {
        environment = "production"
        service     = "shared-postgres"
        tier        = "data"
        namespace   = "data-ns"
      }
      description = "Shared Postgres (TimescaleDB) produced 10+ errors in 5 minutes — 17 databases depend on this."
    }

    mysql_errors = {
      name       = "noizu – Shared MySQL Errors"
      alert_type = "LOGS_BASED_ALERT"
      severity   = "critical"
      condition = {
        compositeQuery = {
          queryType = "builder"
          panelType = "graph"
          builderQueries = {
            A = {
              queryName         = "A"
              dataSource        = "logs"
              aggregateOperator = "count"
              filters = {
                items = [
                  {
                    key   = { key = "severity_text", dataType = "string", type = "tag" }
                    op    = "="
                    value = "ERROR"
                  },
                  {
                    key   = { key = "k8s.namespace.name", dataType = "string", type = "resource" }
                    op    = "="
                    value = "data-ns"
                  },
                  {
                    key   = { key = "k8s.deployment.name", dataType = "string", type = "resource" }
                    op    = "regex"
                    value = "shared-mysql.*"
                  }
                ]
                op = "AND"
              }
            }
          }
        }
        op        = "1"
        target    = 10
        matchType = "4"
      }
      eval_window        = "5m0s"
      frequency          = "1m0s"
      preferred_channels = var.critical_preferred_channels
      labels = {
        environment = "production"
        service     = "shared-mysql"
        tier        = "data"
        namespace   = "data-ns"
      }
      description = "Shared MySQL 8.0 produced 10+ errors in 5 minutes — ghost, matomo, mautic, espocrm, seonaut depend on this."
    }

    # --- Mail (Tier 5) --------------------------------------------------

    mailu_postfix_errors = {
      name       = "noizu – Mailu Postfix Errors"
      alert_type = "LOGS_BASED_ALERT"
      severity   = "warning"
      condition = {
        compositeQuery = {
          queryType = "builder"
          panelType = "graph"
          builderQueries = {
            A = {
              queryName         = "A"
              dataSource        = "logs"
              aggregateOperator = "count"
              filters = {
                items = [
                  {
                    key   = { key = "severity_text", dataType = "string", type = "tag" }
                    op    = "="
                    value = "ERROR"
                  },
                  {
                    key   = { key = "k8s.namespace.name", dataType = "string", type = "resource" }
                    op    = "="
                    value = "mail-ns"
                  }
                ]
                op = "AND"
              }
            }
          }
        }
        op        = "1"
        target    = 5
        matchType = "4"
      }
      eval_window        = "5m0s"
      frequency          = "1m0s"
      preferred_channels = var.warning_preferred_channels
      labels = {
        environment = "production"
        service     = "mailu"
        tier        = "mail"
        namespace   = "mail-ns"
      }
      description = "Mailu mail stack (therobotlives.com) produced 5+ errors in 5 minutes."
    }

    # --- AI/ML (Tier 4-5) -----------------------------------------------

    vllm_errors = {
      name       = "noizu – vLLM Embedding Server Errors"
      alert_type = "LOGS_BASED_ALERT"
      severity   = "warning"
      condition = {
        compositeQuery = {
          queryType = "builder"
          panelType = "graph"
          builderQueries = {
            A = {
              queryName         = "A"
              dataSource        = "logs"
              aggregateOperator = "count"
              filters = {
                items = [
                  {
                    key   = { key = "severity_text", dataType = "string", type = "tag" }
                    op    = "="
                    value = "ERROR"
                  },
                  {
                    key   = { key = "k8s.namespace.name", dataType = "string", type = "resource" }
                    op    = "="
                    value = "ai-ns"
                  },
                  {
                    key   = { key = "k8s.deployment.name", dataType = "string", type = "resource" }
                    op    = "regex"
                    value = "vllm.*"
                  }
                ]
                op = "AND"
              }
            }
          }
        }
        op        = "1"
        target    = 5
        matchType = "4"
      }
      eval_window        = "5m0s"
      frequency          = "1m0s"
      preferred_channels = var.warning_preferred_channels
      labels = {
        environment = "production"
        service     = "vllm"
        tier        = "ai"
        namespace   = "ai-ns"
      }
      description = "vLLM embedding server (e5-mistral-7b, V100 GPU) produced 5+ errors — weaviate vectorizer degraded."
    }

    # --- Platform (Tier 2) ----------------------------------------------

    authentik_errors = {
      name       = "noizu – Authentik Auth Errors"
      alert_type = "LOGS_BASED_ALERT"
      severity   = "critical"
      condition = {
        compositeQuery = {
          queryType = "builder"
          panelType = "graph"
          builderQueries = {
            A = {
              queryName         = "A"
              dataSource        = "logs"
              aggregateOperator = "count"
              filters = {
                items = [
                  {
                    key   = { key = "severity_text", dataType = "string", type = "tag" }
                    op    = "="
                    value = "ERROR"
                  },
                  {
                    key   = { key = "k8s.namespace.name", dataType = "string", type = "resource" }
                    op    = "="
                    value = "platform-ns"
                  },
                  {
                    key   = { key = "k8s.deployment.name", dataType = "string", type = "resource" }
                    op    = "regex"
                    value = "authentik.*"
                  }
                ]
                op = "AND"
              }
            }
          }
        }
        op        = "1"
        target    = 10
        matchType = "4"
      }
      eval_window        = "5m0s"
      frequency          = "1m0s"
      preferred_channels = var.critical_preferred_channels
      labels = {
        environment = "production"
        service     = "authentik"
        tier        = "platform"
        namespace   = "platform-ns"
      }
      description = "Authentik IdP produced 10+ errors in 5 minutes — SSO for auth.noizu.com and auth.derobot.is impacted."
    }

    # --- Secrets (Tier 0) -----------------------------------------------

    infisical_errors = {
      name       = "noizu – Infisical Secret Sync Errors"
      alert_type = "LOGS_BASED_ALERT"
      severity   = "critical"
      condition = {
        compositeQuery = {
          queryType = "builder"
          panelType = "graph"
          builderQueries = {
            A = {
              queryName         = "A"
              dataSource        = "logs"
              aggregateOperator = "count"
              filters = {
                items = [
                  {
                    key   = { key = "severity_text", dataType = "string", type = "tag" }
                    op    = "="
                    value = "ERROR"
                  },
                  {
                    key   = { key = "k8s.namespace.name", dataType = "string", type = "resource" }
                    op    = "regex"
                    value = "infisical.*"
                  }
                ]
                op = "AND"
              }
            }
          }
        }
        op        = "1"
        target    = 3
        matchType = "4"
      }
      eval_window        = "5m0s"
      frequency          = "1m0s"
      preferred_channels = var.critical_preferred_channels
      labels = {
        environment = "production"
        service     = "infisical"
        tier        = "secrets"
        namespace   = "infisical"
      }
      description = "Infisical operator errors — secret sync to all namespaces may be stalled."
    }
  }
}

# ---------------------------------------------------------------------------
# V2 Alert Resources (for_each)
# ---------------------------------------------------------------------------

resource "signoz_alert" "v2" {
  for_each = local.signoz_v2_alerts

  alert      = each.value.name
  alert_type = each.value.alert_type
  severity   = each.value.severity
  condition  = jsonencode(each.value.condition)
  labels     = each.value.labels

  eval_window = each.value.eval_window
  frequency   = each.value.frequency

  preferred_channels = each.value.preferred_channels
  description        = each.value.description

  rule_type      = "threshold_rule"
  disabled       = !var.alerts_enabled
  version        = "v5"


  notification_settings = {
    group_by = ["alertname", "service", "severity"]
    renotify = {
      interval     = "30m0s"
      alert_states = ["firing"]
    }
  }
}

# ---------------------------------------------------------------------------
# Metric-Based Alerts — Data Tier
# ---------------------------------------------------------------------------

resource "signoz_alert" "postgres_memory_high" {
  alert      = "noizu – Shared Postgres Memory High"
  alert_type = "METRIC_BASED_ALERT"
  severity   = "warning"

  condition = jsonencode({
    compositeQuery = {
      queryType = "builder"
      panelType = "graph"
      builderQueries = {
        A = {
          queryName         = "A"
          dataSource        = "metrics"
          aggregateOperator = "avg"
          aggregateAttribute = {
            key      = "k8s.pod.memory.usage"
            dataType = "float64"
            type     = "Gauge"
          }
          filters = {
            items = [
              {
                key   = { key = "k8s.namespace.name", dataType = "string", type = "resource" }
                op    = "="
                value = "data-ns"
              },
              {
                key   = { key = "k8s.pod.name", dataType = "string", type = "resource" }
                op    = "regex"
                value = "shared-postgres.*"
              }
            ]
            op = "AND"
          }
        }
      }
    }
    op         = "1"
    target     = 3221225472
    matchType  = "4"
    targetUnit = "bytes"
  })

  labels = {
    environment = "production"
    service     = "shared-postgres"
    tier        = "data"
    namespace   = "data-ns"
  }

  eval_window = "5m0s"
  frequency   = "1m0s"

  preferred_channels = var.warning_preferred_channels
  description        = "Shared Postgres (TimescaleDB) memory exceeds 3 GiB (limit: 4 GiB) — 17 app databases at risk."

  rule_type      = "threshold_rule"
  disabled       = !var.alerts_enabled
  version        = "v4"


  notification_settings = {
    group_by = ["alertname", "service"]
    renotify = {
      interval     = "30m0s"
      alert_states = ["firing"]
    }
  }
}

resource "signoz_alert" "clickhouse_memory_high" {
  alert      = "noizu – ClickHouse Memory High"
  alert_type = "METRIC_BASED_ALERT"
  severity   = "critical"

  condition = jsonencode({
    compositeQuery = {
      queryType = "builder"
      panelType = "graph"
      builderQueries = {
        A = {
          queryName         = "A"
          dataSource        = "metrics"
          aggregateOperator = "avg"
          aggregateAttribute = {
            key      = "k8s.pod.memory.usage"
            dataType = "float64"
            type     = "Gauge"
          }
          filters = {
            items = [
              {
                key   = { key = "k8s.namespace.name", dataType = "string", type = "resource" }
                op    = "="
                value = "data-ns"
              },
              {
                key   = { key = "k8s.pod.name", dataType = "string", type = "resource" }
                op    = "regex"
                value = "shared-clickhouse.*"
              }
            ]
            op = "AND"
          }
        }
      }
    }
    op         = "1"
    target     = 12884901888
    matchType  = "4"
    targetUnit = "bytes"
  })

  labels = {
    environment = "production"
    service     = "shared-clickhouse"
    tier        = "data"
    namespace   = "data-ns"
  }

  eval_window = "5m0s"
  frequency   = "1m0s"

  preferred_channels = var.critical_preferred_channels
  description        = "ClickHouse memory exceeds 12 GiB (max_memory: 12GB, limit: 15 GiB) — SigNoz + PostHog backend."

  rule_type      = "threshold_rule"
  disabled       = !var.alerts_enabled
  version        = "v4"


  notification_settings = {
    group_by = ["alertname", "service"]
    renotify = {
      interval     = "30m0s"
      alert_states = ["firing"]
    }
  }
}

resource "signoz_alert" "mysql_memory_high" {
  alert      = "noizu – Shared MySQL Memory High"
  alert_type = "METRIC_BASED_ALERT"
  severity   = "warning"

  condition = jsonencode({
    compositeQuery = {
      queryType = "builder"
      panelType = "graph"
      builderQueries = {
        A = {
          queryName         = "A"
          dataSource        = "metrics"
          aggregateOperator = "avg"
          aggregateAttribute = {
            key      = "k8s.pod.memory.usage"
            dataType = "float64"
            type     = "Gauge"
          }
          filters = {
            items = [
              {
                key   = { key = "k8s.namespace.name", dataType = "string", type = "resource" }
                op    = "="
                value = "data-ns"
              },
              {
                key   = { key = "k8s.pod.name", dataType = "string", type = "resource" }
                op    = "regex"
                value = "shared-mysql.*"
              }
            ]
            op = "AND"
          }
        }
      }
    }
    op         = "1"
    target     = 6442450944
    matchType  = "4"
    targetUnit = "bytes"
  })

  labels = {
    environment = "production"
    service     = "shared-mysql"
    tier        = "data"
    namespace   = "data-ns"
  }

  eval_window = "5m0s"
  frequency   = "1m0s"

  preferred_channels = var.warning_preferred_channels
  description        = "Shared MySQL memory exceeds 6 GiB (limit: 8 GiB) — ghost, matomo, mautic, espocrm, seonaut at risk."

  rule_type      = "threshold_rule"
  disabled       = !var.alerts_enabled
  version        = "v4"


  notification_settings = {
    group_by = ["alertname", "service"]
    renotify = {
      interval     = "30m0s"
      alert_states = ["firing"]
    }
  }
}

resource "signoz_alert" "redis_memory_high" {
  alert      = "noizu – Shared Redis Memory High"
  alert_type = "METRIC_BASED_ALERT"
  severity   = "warning"

  condition = jsonencode({
    compositeQuery = {
      queryType = "builder"
      panelType = "graph"
      builderQueries = {
        A = {
          queryName         = "A"
          dataSource        = "metrics"
          aggregateOperator = "avg"
          aggregateAttribute = {
            key      = "k8s.pod.memory.usage"
            dataType = "float64"
            type     = "Gauge"
          }
          filters = {
            items = [
              {
                key   = { key = "k8s.namespace.name", dataType = "string", type = "resource" }
                op    = "="
                value = "data-ns"
              },
              {
                key   = { key = "k8s.pod.name", dataType = "string", type = "resource" }
                op    = "regex"
                value = "shared-(redis|valkey).*"
              }
            ]
            op = "AND"
          }
          groupBy = [
            { key = "k8s.pod.name", dataType = "string", type = "resource" }
          ]
        }
      }
    }
    op         = "1"
    target     = 805306368
    matchType  = "4"
    targetUnit = "bytes"
  })

  labels = {
    environment = "production"
    service     = "shared-redis-valkey"
    tier        = "data"
    namespace   = "data-ns"
  }

  eval_window = "5m0s"
  frequency   = "1m0s"

  preferred_channels = var.warning_preferred_channels
  description        = "Shared Redis or Valkey memory exceeds 768 MiB (limit: 1 GiB) — cache evictions imminent."

  rule_type      = "threshold_rule"
  disabled       = !var.alerts_enabled
  version        = "v4"


  notification_settings = {
    group_by = ["alertname", "k8s.pod.name"]
    renotify = {
      interval     = "30m0s"
      alert_states = ["firing"]
    }
  }
}

# ---------------------------------------------------------------------------
# Metric-Based Alerts — AI/ML Tier
# ---------------------------------------------------------------------------

resource "signoz_alert" "vllm_gpu_memory" {
  alert      = "noizu – vLLM GPU Memory Pressure"
  alert_type = "METRIC_BASED_ALERT"
  severity   = "warning"

  condition = jsonencode({
    compositeQuery = {
      queryType = "builder"
      panelType = "graph"
      builderQueries = {
        A = {
          queryName         = "A"
          dataSource        = "metrics"
          aggregateOperator = "avg"
          aggregateAttribute = {
            key      = "k8s.pod.memory.usage"
            dataType = "float64"
            type     = "Gauge"
          }
          filters = {
            items = [
              {
                key   = { key = "k8s.namespace.name", dataType = "string", type = "resource" }
                op    = "="
                value = "ai-ns"
              },
              {
                key   = { key = "k8s.pod.name", dataType = "string", type = "resource" }
                op    = "regex"
                value = "vllm.*"
              }
            ]
            op = "AND"
          }
        }
      }
    }
    op         = "1"
    target     = 20971520000
    matchType  = "4"
    targetUnit = "bytes"
  })

  labels = {
    environment = "production"
    service     = "vllm"
    tier        = "ai"
    namespace   = "ai-ns"
  }

  eval_window = "5m0s"
  frequency   = "1m0s"

  preferred_channels = var.warning_preferred_channels
  description        = "vLLM pod memory exceeds 20 GiB (limit: 24 GiB, V100 16GB GPU) — OOM risk for e5-mistral-7b."

  rule_type      = "threshold_rule"
  disabled       = !var.alerts_enabled
  version        = "v4"


  notification_settings = {
    group_by = ["alertname", "service"]
    renotify = {
      interval     = "30m0s"
      alert_states = ["firing"]
    }
  }
}

resource "signoz_alert" "weaviate_memory_high" {
  alert      = "noizu – Weaviate Memory High"
  alert_type = "METRIC_BASED_ALERT"
  severity   = "warning"

  condition = jsonencode({
    compositeQuery = {
      queryType = "builder"
      panelType = "graph"
      builderQueries = {
        A = {
          queryName         = "A"
          dataSource        = "metrics"
          aggregateOperator = "avg"
          aggregateAttribute = {
            key      = "k8s.pod.memory.usage"
            dataType = "float64"
            type     = "Gauge"
          }
          filters = {
            items = [
              {
                key   = { key = "k8s.namespace.name", dataType = "string", type = "resource" }
                op    = "="
                value = "ai-ns"
              },
              {
                key   = { key = "k8s.pod.name", dataType = "string", type = "resource" }
                op    = "regex"
                value = "weaviate.*"
              }
            ]
            op = "AND"
          }
        }
      }
    }
    op         = "1"
    target     = 10737418240
    matchType  = "4"
    targetUnit = "bytes"
  })

  labels = {
    environment = "production"
    service     = "weaviate"
    tier        = "ai"
    namespace   = "ai-ns"
  }

  eval_window = "5m0s"
  frequency   = "1m0s"

  preferred_channels = var.warning_preferred_channels
  description        = "Weaviate vector DB memory exceeds 10 GiB (limit: 12 GiB) — NPL memory system degraded."

  rule_type      = "threshold_rule"
  disabled       = !var.alerts_enabled
  version        = "v4"


  notification_settings = {
    group_by = ["alertname", "service"]
    renotify = {
      interval     = "30m0s"
      alert_states = ["firing"]
    }
  }
}

# ---------------------------------------------------------------------------
# Metric-Based Alerts — Infrastructure
# ---------------------------------------------------------------------------

resource "signoz_alert" "node_disk_pressure" {
  alert      = "noizu – Node Disk Usage High"
  alert_type = "METRIC_BASED_ALERT"
  severity   = "critical"

  condition = jsonencode({
    compositeQuery = {
      queryType = "builder"
      panelType = "graph"
      builderQueries = {
        A = {
          queryName         = "A"
          dataSource        = "metrics"
          aggregateOperator = "avg"
          aggregateAttribute = {
            key      = "system.filesystem.utilization"
            dataType = "float64"
            type     = "Gauge"
          }
          filters = {
            items = [
              {
                key   = { key = "type", dataType = "string", type = "tag" }
                op    = "="
                value = "ext4"
              }
            ]
            op = "AND"
          }
          groupBy = [
            { key = "k8s.node.name", dataType = "string", type = "resource" }
          ]
        }
      }
    }
    op        = "1"
    target    = 0.85
    matchType = "4"
  })

  labels = {
    environment = "production"
    service     = "infra-nodes"
    tier        = "infrastructure"
  }

  eval_window = "5m0s"
  frequency   = "1m0s"

  preferred_channels = var.critical_preferred_channels
  description        = "Node filesystem utilization exceeds 85% — ~985 GiB total PVC storage at risk of pod evictions."

  rule_type      = "threshold_rule"
  disabled       = !var.alerts_enabled
  version        = "v4"


  notification_settings = {
    group_by = ["alertname", "k8s.node.name"]
    renotify = {
      interval     = "30m0s"
      alert_states = ["firing"]
    }
  }
}

resource "signoz_alert" "pod_restart_loop" {
  alert      = "noizu – Pod Restart Loop"
  alert_type = "METRIC_BASED_ALERT"
  severity   = "warning"

  condition = jsonencode({
    compositeQuery = {
      queryType = "builder"
      panelType = "graph"
      builderQueries = {
        A = {
          queryName         = "A"
          dataSource        = "metrics"
          aggregateOperator = "rate"
          aggregateAttribute = {
            key      = "k8s.pod.restart.count"
            dataType = "float64"
            type     = "Sum"
          }
          filters = { items = [], op = "AND" }
          groupBy = [
            { key = "k8s.namespace.name", dataType = "string", type = "resource" },
            { key = "k8s.pod.name", dataType = "string", type = "resource" }
          ]
        }
      }
    }
    op        = "1"
    target    = 3
    matchType = "4"
  })

  labels = {
    environment = "production"
    service     = "noizu-platform"
    tier        = "infrastructure"
  }

  eval_window = "15m0s"
  frequency   = "5m0s"

  preferred_channels = var.warning_preferred_channels
  description        = "Pod restarted 3+ times in 15 minutes — possible CrashLoopBackOff across any namespace."

  rule_type      = "threshold_rule"
  disabled       = !var.alerts_enabled
  version        = "v4"


  notification_settings = {
    group_by = ["alertname", "k8s.namespace.name", "k8s.pod.name"]
    renotify = {
      interval     = "1h0m0s"
      alert_states = ["firing"]
    }
  }
}

# ---------------------------------------------------------------------------
# Metric-Based Alerts — Mail
# ---------------------------------------------------------------------------

resource "signoz_alert" "mailu_dovecot_storage" {
  alert      = "noizu – Mailu Dovecot Storage High"
  alert_type = "METRIC_BASED_ALERT"
  severity   = "warning"

  condition = jsonencode({
    compositeQuery = {
      queryType = "builder"
      panelType = "graph"
      builderQueries = {
        A = {
          queryName         = "A"
          dataSource        = "metrics"
          aggregateOperator = "avg"
          aggregateAttribute = {
            key      = "k8s.volume.usage"
            dataType = "float64"
            type     = "Gauge"
          }
          filters = {
            items = [
              {
                key   = { key = "k8s.namespace.name", dataType = "string", type = "resource" }
                op    = "="
                value = "mail-ns"
              },
              {
                key   = { key = "k8s.persistentvolumeclaim.name", dataType = "string", type = "resource" }
                op    = "regex"
                value = ".*dovecot.*"
              }
            ]
            op = "AND"
          }
        }
      }
    }
    op         = "1"
    target     = 42949672960
    matchType  = "4"
    targetUnit = "bytes"
  })

  labels = {
    environment = "production"
    service     = "mailu-dovecot"
    tier        = "mail"
    namespace   = "mail-ns"
  }

  eval_window = "5m0s"
  frequency   = "5m0s"

  preferred_channels = var.warning_preferred_channels
  description        = "Dovecot mailbox storage exceeds 40 GiB (PVC: 50 GiB) — therobotlives.com mail delivery at risk."

  rule_type      = "threshold_rule"
  disabled       = !var.alerts_enabled
  version        = "v4"


  notification_settings = {
    group_by = ["alertname", "service"]
    renotify = {
      interval     = "1h0m0s"
      alert_states = ["firing"]
    }
  }
}

# ---------------------------------------------------------------------------
# Metric-Based Alerts — Docker Registry
# ---------------------------------------------------------------------------

resource "signoz_alert" "registry_storage" {
  alert      = "noizu – Docker Registry Storage High"
  alert_type = "METRIC_BASED_ALERT"
  severity   = "warning"

  condition = jsonencode({
    compositeQuery = {
      queryType = "builder"
      panelType = "graph"
      builderQueries = {
        A = {
          queryName         = "A"
          dataSource        = "metrics"
          aggregateOperator = "avg"
          aggregateAttribute = {
            key      = "k8s.volume.usage"
            dataType = "float64"
            type     = "Gauge"
          }
          filters = {
            items = [
              {
                key   = { key = "k8s.namespace.name", dataType = "string", type = "resource" }
                op    = "="
                value = "platform-ns"
              },
              {
                key   = { key = "k8s.persistentvolumeclaim.name", dataType = "string", type = "resource" }
                op    = "regex"
                value = "registry-data.*"
              }
            ]
            op = "AND"
          }
        }
      }
    }
    op         = "1"
    target     = 429496729600
    matchType  = "4"
    targetUnit = "bytes"
  })

  labels = {
    environment = "production"
    service     = "docker-registry"
    tier        = "platform"
    namespace   = "platform-ns"
  }

  eval_window = "5m0s"
  frequency   = "5m0s"

  preferred_channels = var.warning_preferred_channels
  description        = "Docker registry (ops.noizu.com) storage exceeds 400 GiB (PVC: 500 GiB) — image pushes will fail."

  rule_type      = "threshold_rule"
  disabled       = !var.alerts_enabled
  version        = "v4"


  notification_settings = {
    group_by = ["alertname", "service"]
    renotify = {
      interval     = "1h0m0s"
      alert_states = ["firing"]
    }
  }
}
