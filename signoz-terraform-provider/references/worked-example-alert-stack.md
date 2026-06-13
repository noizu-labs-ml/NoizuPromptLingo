# Worked Example: Alert Stack + Dashboard + CI

This example provisions a complete observability IaC setup for a web service:
- 2 alerts (logs-based error rate, metrics-based latency)
- 1 dashboard (request rate + error rate panels)
- Terraform module structure
- CI/CD integration pattern

---

## Directory Layout

```
signoz-iac/
├── main.tf
├── variables.tf
├── outputs.tf
├── alerts.tf
├── dashboards.tf
└── .terraform.lock.hcl
```

---

## `main.tf` — Provider Setup

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    signoz = {
      source  = "SigNoz/signoz"
      version = "~> 0.0.11"
    }
  }
  backend "s3" {
    bucket = "gnp-terraform-state"
    key    = "signoz/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "signoz" {
  endpoint     = var.signoz_endpoint
  access_token = var.signoz_access_token
}
```

## `variables.tf`

```hcl
variable "signoz_endpoint" {
  type        = string
  description = "SigNoz instance URL (no trailing slash)"
}

variable "signoz_access_token" {
  type        = string
  sensitive   = true
  description = "SigNoz Service Account token"
}

variable "service_name" {
  type        = string
  description = "Service being monitored"
  default     = "gnp-backend"
}

variable "error_rate_threshold" {
  type        = number
  description = "Max errors per 5 min before alert fires"
  default     = 10
}

variable "p99_latency_threshold_ms" {
  type        = number
  description = "Max p99 latency in ms before alert fires"
  default     = 2000
}
```

---

## `alerts.tf` — Two Alert Resources

```hcl
# Alert 1: Log-based error spike
resource "signoz_alert" "error_spike" {
  alert          = "${var.service_name} — Error Spike"
  alert_type     = "LOGS_BASED_ALERT"
  severity       = "critical"
  rule_type      = "threshold_rule"
  version        = "v5"
  schema_version = "v2alpha1"
  eval_window    = "5m0s"
  frequency      = "1m0s"
  disabled       = false
  broadcast_to_all = true
  description    = "Error count {{.Value}} exceeded ${var.error_rate_threshold} in {{.EvalWindow}} for ${var.service_name}"

  condition = jsonencode({
    op     = ">"
    target = var.error_rate_threshold
    compositeQuery = {
      queryType = "builder"
      builderQueries = {
        A = {
          dataSource        = "logs"
          queryName         = "A"
          aggregateOperator = "count"
          filters = {
            op = "AND"
            items = [
              {
                key   = { key = "severity_text", dataType = "string", type = "tag", isColumn = false }
                op    = "="
                value = "ERROR"
              },
              {
                key   = { key = "service_name", dataType = "string", type = "resource", isColumn = false }
                op    = "="
                value = var.service_name
              }
            ]
          }
          groupBy = []
          legend  = ""
        }
      }
    }
  })

  notification_settings = {
    renotify = {
      interval     = "1h0m0s"
      alert_states = ["firing"]
    }
    group_by   = []
    use_policy = false
  }
}

# Alert 2: Metrics-based p99 latency
resource "signoz_alert" "high_latency" {
  alert          = "${var.service_name} — High P99 Latency"
  alert_type     = "METRIC_BASED_ALERT"
  severity       = "warning"
  rule_type      = "threshold_rule"
  version        = "v5"
  schema_version = "v2alpha1"
  eval_window    = "5m0s"
  frequency      = "2m0s"
  disabled       = false
  broadcast_to_all = true
  description    = "P99 latency {{.Value}}ms exceeded ${var.p99_latency_threshold_ms}ms for ${var.service_name}"

  condition = jsonencode({
    op     = ">"
    target = var.p99_latency_threshold_ms
    compositeQuery = {
      queryType = "builder"
      builderQueries = {
        A = {
          dataSource        = "metrics"
          queryName         = "A"
          aggregateOperator = "p99"
          aggregateAttribute = {
            key      = "http_server_duration_milliseconds"
            dataType = "float64"
            type     = "Histogram"
            isColumn = false
          }
          filters = {
            op    = "AND"
            items = [
              {
                key   = { key = "service_name", dataType = "string", type = "resource", isColumn = false }
                op    = "="
                value = var.service_name
              }
            ]
          }
          groupBy = []
          legend  = ""
        }
      }
    }
  })
}
```

---

## `dashboards.tf` — Service Overview Dashboard

```hcl
resource "signoz_dashboard" "service_overview" {
  name        = "${var.service_name}-overview"
  title       = "${var.service_name} — Service Overview"
  description = "Request rate, error rate, and p99 latency for ${var.service_name}"
  version     = "v4"
  tags        = [var.service_name, "slo", "http"]

  collapsable_rows_migrated = false
  uploaded_grafana          = false
  panel_map                 = jsonencode({})
  variables                 = jsonencode({})

  layout = jsonencode([
    { i = "w-1", x = 0, y = 0, w = 6, h = 6, moved = false, static = false },
    { i = "w-2", x = 6, y = 0, w = 6, h = 6, moved = false, static = false },
  ])

  widgets = jsonencode([
    {
      id         = "w-1"
      title      = "HTTP Request Rate"
      description = ""
      panelTypes = "graph"
      yAxisUnit  = "reqps"
      fillSpans  = false
      query = {
        queryType = "builder"
        builder = {
          queryData = [{
            dataSource        = "metrics"
            queryName         = "A"
            aggregateOperator = "rate"
            aggregateAttribute = {
              key      = "http_server_duration_milliseconds_count"
              dataType = "float64"
              type     = "Counter"
              isColumn = false
            }
            filters = {
              op = "AND"
              items = []
            }
            groupBy = [{ key = "service_name", dataType = "string", type = "resource", isColumn = false }]
            legend  = "{{service_name}}"
          }]
          queryFormulas = []
        }
      }
    },
    {
      id         = "w-2"
      title      = "Error Rate"
      description = ""
      panelTypes = "graph"
      yAxisUnit  = "percent"
      fillSpans  = false
      query = {
        queryType = "builder"
        builder = {
          queryData = [{
            dataSource        = "logs"
            queryName         = "A"
            aggregateOperator = "count"
            filters = {
              op    = "AND"
              items = [
                {
                  key   = { key = "severity_text", dataType = "string", type = "tag", isColumn = false }
                  op    = "="
                  value = "ERROR"
                }
              ]
            }
            groupBy = []
            legend  = "Errors"
          }]
          queryFormulas = []
        }
      }
    }
  ])
}
```

---

## `outputs.tf`

```hcl
output "error_spike_alert_id" {
  value       = signoz_alert.error_spike.id
  description = "UUID of the error spike alert"
}

output "high_latency_alert_id" {
  value       = signoz_alert.high_latency.id
  description = "UUID of the high latency alert"
}

output "dashboard_id" {
  value       = signoz_dashboard.service_overview.id
  description = "UUID of the service overview dashboard"
}
```

---

## CI/CD (GitHub Actions)

```yaml
name: SigNoz IaC

on:
  push:
    branches: [main]
    paths: ['signoz-iac/**']
  pull_request:
    paths: ['signoz-iac/**']

jobs:
  plan:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: signoz-iac
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.9.x"
      - run: terraform init
        env:
          SIGNOZ_ACCESS_TOKEN: ${{ secrets.SIGNOZ_ACCESS_TOKEN }}
          SIGNOZ_ENDPOINT: ${{ secrets.SIGNOZ_ENDPOINT }}
      - run: terraform plan -var="signoz_endpoint=$SIGNOZ_ENDPOINT" -var="signoz_access_token=$SIGNOZ_ACCESS_TOKEN"
        env:
          SIGNOZ_ACCESS_TOKEN: ${{ secrets.SIGNOZ_ACCESS_TOKEN }}
          SIGNOZ_ENDPOINT: ${{ secrets.SIGNOZ_ENDPOINT }}

  apply:
    needs: plan
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: signoz-iac
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.9.x"
      - run: terraform init && terraform apply -auto-approve -var="signoz_endpoint=$SIGNOZ_ENDPOINT" -var="signoz_access_token=$SIGNOZ_ACCESS_TOKEN"
        env:
          SIGNOZ_ACCESS_TOKEN: ${{ secrets.SIGNOZ_ACCESS_TOKEN }}
          SIGNOZ_ENDPOINT: ${{ secrets.SIGNOZ_ENDPOINT }}
```

---

## Verification Checklist

After apply:
- [ ] `terraform plan` shows zero changes (confirms no drift)
- [ ] Alert visible in SigNoz UI under Alerts
- [ ] Dashboard visible in SigNoz UI under Dashboards
- [ ] `terraform output` shows UUIDs that match UI URLs
- [ ] Trigger test event — verify alert fires and notification arrives
