# SigNoz Terraform Provider — Complete Reference

> **Training data gap warning**: The `SigNoz/signoz` Terraform provider is a young, rapidly-changing provider (v0.0.x). Most LLM training data predates v0.0.8+ schema changes. Always verify against the [Terraform Registry](https://registry.terraform.io/providers/SigNoz/signoz/latest/docs) and the [GitHub repo](https://github.com/SigNoz/terraform-provider-signoz).

---

## Version History (Key Changes)

| Version | Date | Breaking / Notable |
|---------|------|--------------------|
| v0.0.11 | Nov 2025 | Fixed `condition` extra-fields serialization bug — upgrades eliminate perpetual drift |
| v0.0.10 | Nov 2025 | Added `notification_settings` to alert data source |
| v0.0.9  | Sep 2025 | **Breaking**: alert labels no longer synced from API — remove from state if upgrading |
| v0.0.8  | Jun 2025 | **Breaking**: dashboard schema updated (`widgets` structure changed) — re-import dashboards |
| v0.0.7  | May 2025 | Go 1.23 upgrade, no schema changes |
| v0.0.4  | —       | First widely-referenced stable version |

---

## Provider Configuration

### Required Inputs

| Argument | Env Var | Type | Notes |
|----------|---------|------|-------|
| `endpoint` | `SIGNOZ_ENDPOINT` | string | Full URL, no trailing slash: `https://signoz.example.com` |
| `access_token` | `SIGNOZ_ACCESS_TOKEN` | string | Service Account token — NOT a user API key |

### HCL Block

```hcl
provider "signoz" {
  endpoint     = var.signoz_endpoint
  access_token = var.signoz_access_token
}
```

**Never hardcode tokens in `.tf` files.** Use variables backed by env vars or a secrets manager.

### Service Account Setup

1. SigNoz UI → Settings → Service Accounts → New Service Account
2. Assign role: `org-admin` for full access, or resource-scoped for least privilege
3. Generate token → store in Infisical/Vault/GitHub Secrets as `SIGNOZ_ACCESS_TOKEN`

---

## Resource: `signoz_alert`

### All Fields

| Field | Required | Type | Notes |
|-------|----------|------|-------|
| `alert` | yes | string | Alert display name |
| `alert_type` | yes | string | See Alert Types table |
| `severity` | yes | string | `critical`, `warning`, `info`, `p1`–`p5` |
| `rule_type` | yes | string | Always `"threshold_rule"` currently |
| `version` | yes | string | Always `"v5"` for current SigNoz |
| `schema_version` | yes | string | Always `"v2alpha1"` for current SigNoz |
| `condition` | yes | string (JSON) | JSON-encoded condition object — see Condition Schema |
| `eval_window` | yes | string | Go duration: `"5m0s"` — **must include `0s` suffix** |
| `frequency` | yes | string | Go duration: `"1m0s"` — same format |
| `description` | no | string | Supports Go template vars: `{{.Value}}`, `{{.EvalWindow}}` |
| `disabled` | no | bool | Default `false` |
| `broadcast_to_all` | no | bool | Notify all channels if `true` |
| `notification_settings` | no | object | Renotification and grouping — see below |
| `labels` | no | map(string) | **Removed from API in v0.0.9** — do not use |

**Read-only**: `id`

### Alert Types

| Value | Meaning |
|-------|---------|
| `LOGS_BASED_ALERT` | Query over log data |
| `METRIC_BASED_ALERT` | Query over metrics |
| `TRACES_BASED_ALERT` | Query over trace spans |
| `EXCEPTIONS_BASED_ALERT` | Exception tracking |
| `ANOMALY_DETECTION_ALERT` | ML-based anomaly |

### Condition Schema (JSON)

The `condition` field is a **JSON string**. The structure varies by `queryType`:

```json
{
  "op": ">",
  "target": 10,
  "compositeQuery": {
    "queryType": "builder",
    "builderQueries": {
      "A": {
        "dataSource": "logs|metrics|traces",
        "queryName": "A",
        "aggregateOperator": "count|avg|sum|max|min|p99",
        "filters": { "op": "AND", "items": [] },
        "groupBy": [],
        "legend": ""
      }
    }
  }
}
```

For PromQL-style metrics:
```json
{
  "op": ">",
  "target": 0.05,
  "compositeQuery": {
    "queryType": "promql",
    "promQueries": {
      "A": { "query": "rate(http_requests_total{status=~\"5..\"}[5m])", "disabled": false }
    }
  }
}
```

### notification_settings Schema

```hcl
notification_settings = {
  renotify = {
    interval     = "1h0m0s"
    alert_states = ["firing", "resolved"]  # BUG: API may omit this — see Known Quirks
  }
  group_by   = []
  use_policy = false
}
```

### Example: Logs-Based Alert

```hcl
resource "signoz_alert" "service_errors" {
  alert          = "Service Error Spike"
  alert_type     = "LOGS_BASED_ALERT"
  severity       = "critical"
  rule_type      = "threshold_rule"
  version        = "v5"
  schema_version = "v2alpha1"
  eval_window    = "5m0s"
  frequency      = "1m0s"
  disabled       = false
  broadcast_to_all = true
  description    = "Error count {{.Value}} exceeded threshold in {{.EvalWindow}}"

  condition = jsonencode({
    op     = ">"
    target = 5
    compositeQuery = {
      queryType = "builder"
      builderQueries = {
        A = {
          dataSource        = "logs"
          queryName         = "A"
          aggregateOperator = "count"
          filters = {
            op    = "AND"
            items = [
              { key = { key = "severity_text", dataType = "string", type = "tag" }, op = "=", value = "ERROR" }
            ]
          }
        }
      }
    }
  })
}
```

### Import Alert

```bash
# UUID from SigNoz UI: Settings → Alerts → click alert → UUID in URL
terraform import signoz_alert.service_errors <UUID>
```

---

## Resource: `signoz_dashboard`

### All Fields

| Field | Required | Type | Notes |
|-------|----------|------|-------|
| `name` | yes | string | Internal identifier (slug-style) |
| `title` | yes | string | Display name in UI |
| `description` | yes | string | Dashboard purpose |
| `version` | yes | string | Always `"v4"` for current SigNoz |
| `layout` | yes | string (JSON) | Grid positioning for each widget |
| `widgets` | yes | string (JSON) | Array of widget configs |
| `variables` | yes | string (JSON) | Map of template variables |
| `collapsable_rows_migrated` | yes | bool | Always `false` for new dashboards |
| `uploaded_grafana` | yes | bool | Always `false` unless importing from Grafana |
| `panel_map` | no | string (JSON) | Almost always `jsonencode({})` |
| `source` | no | string | Defaults to `<SIGNOZ_ENDPOINT>/dashboard` |
| `tags` | no | list(string) | Categorization labels |

**Read-only**: `id`, `created_at`, `created_by`, `updated_at`, `updated_by`

### Layout Schema

Each item in the layout array positions one widget on the grid:

```json
[
  {
    "i": "widget-uuid-1",
    "x": 0, "y": 0,
    "w": 6, "h": 8,
    "moved": false,
    "static": false
  }
]
```

- `i` must match a widget's `id` field exactly
- Grid is 12 columns wide; `w: 6` = half width
- `h` is in row units (1 unit ≈ 40px)

### Widget Schema (single widget)

```json
{
  "id": "widget-uuid-1",
  "title": "Request Rate",
  "description": "",
  "panelTypes": "graph",
  "yAxisUnit": "reqps",
  "fillSpans": false,
  "query": {
    "queryType": "builder",
    "builder": {
      "queryData": [
        {
          "dataSource": "metrics",
          "queryName": "A",
          "aggregateOperator": "rate",
          "aggregateAttribute": {
            "key": "http_requests_total",
            "dataType": "float64",
            "type": "Gauge",
            "isColumn": false
          },
          "filters": { "op": "AND", "items": [] },
          "groupBy": [],
          "legend": "{{service_name}}"
        }
      ],
      "queryFormulas": []
    }
  }
}
```

**Panel types**: `graph`, `stat`, `table`, `list`, `pie`, `bar`, `histogram`

### Variables Schema

```json
{
  "env": {
    "id": "env",
    "name": "env",
    "description": "Deployment environment",
    "type": "QUERY",
    "queryValue": "SELECT DISTINCT JSONExtractString(labels, 'env') FROM signoz_metrics.time_series",
    "customValue": "",
    "multiSelect": false,
    "sort": "ASC",
    "selectedValue": ["production"],
    "modificationUUID": "uuid-v4-string"
  }
}
```

For static lists use `"type": "CUSTOM"` with `"customValue": "option1,option2"`.

### Example: Minimal Dashboard

```hcl
locals {
  widget_id = "w-${random_id.widget.hex}"
}

resource "signoz_dashboard" "service_overview" {
  name        = "service-overview"
  title       = "Service Overview"
  description = "Request rate and error rate for all services"
  version     = "v4"

  collapsable_rows_migrated = false
  uploaded_grafana          = false
  panel_map                 = jsonencode({})
  variables                 = jsonencode({})
  tags                      = ["services", "slo"]

  layout = jsonencode([
    { i = "w-1", x = 0, y = 0, w = 12, h = 6, moved = false, static = false }
  ])

  widgets = jsonencode([
    {
      id         = "w-1"
      title      = "HTTP Request Rate"
      panelTypes = "graph"
      yAxisUnit  = "reqps"
      query = {
        queryType = "builder"
        builder = {
          queryData = [{
            dataSource        = "metrics"
            queryName         = "A"
            aggregateOperator = "rate"
            aggregateAttribute = {
              key      = "http_requests_total"
              dataType = "float64"
              type     = "Gauge"
              isColumn = false
            }
            filters = { op = "AND", items = [] }
            groupBy = []
            legend  = "{{service_name}}"
          }]
          queryFormulas = []
        }
      }
    }
  ])
}
```

### Import Dashboard

```bash
# UUID from UI: https://<host>/dashboard/<UUID>
terraform import signoz_dashboard.service_overview <UUID>
terraform show -no-color > imported_dashboard.tf
# Copy the resource block from output back into your .tf file
terraform plan  # should show no changes
```

---

## Data Sources

Both resources have matching data sources for read-only lookups:

```hcl
data "signoz_alert" "existing" {
  id = "<alert-uuid>"
}

data "signoz_dashboard" "existing" {
  id = "<dashboard-uuid>"
}
```

Use data sources to reference IDs across modules without importing into state.

---

## Known Quirks (Read This Before Debugging Drift)

### 1. `eval_window` / `frequency` require `0s` suffix
```
"5m"    → WRONG — will cause error or unexpected behavior
"5m0s"  → CORRECT
"1h0m0s" → CORRECT for 1 hour
```
This is Go's `time.Duration.String()` format. The provider doesn't normalize input.

### 2. Alert v2 round-trip bug (issue #83, open as of Nov 2025)
The API for v2 alerts omits `severity` and `renotify.alert_states` in responses, but the resource schema marks these as required. Result: `terraform plan` shows a change on every run even when nothing has changed.

**Workaround**: Explicitly set both in config and they'll match after the first apply. If drift persists, check whether the open PR fixing this is merged in your provider version.

### 3. `condition` extra fields (fixed in v0.0.11)
Prior to v0.0.11, the condition serializer included internal fields not in the original config, causing perpetual drift. **Pin to `~> 0.0.11` or later.**

### 4. Alert labels removed (v0.0.9 breaking change)
Labels were previously synced from the API. In v0.0.9+, they are not. If you're upgrading from v0.0.8 or earlier, run `terraform state rm` on any alerts that have `labels` in state, then re-import.

### 5. Dashboard schema changed in v0.0.8
The `widgets` JSON structure changed. Dashboards written for v0.0.7 or earlier need to be re-imported with `terraform import` after upgrading.

### 6. `collapsable_rows_migrated` and `uploaded_grafana` are required but meaningless
Both must be present in your config. For new dashboards, always `false`. These are internal migration flags that SigNoz didn't make optional in the provider schema.

### 7. `panel_map` must be `jsonencode({})` not omitted
Omitting `panel_map` does not mean "empty" — it causes a schema validation error. Always set `panel_map = jsonencode({})` for standard dashboards.

### 8. JSON ordering causes spurious diff
Terraform's `jsonencode()` produces deterministic key ordering. If you mix raw JSON strings with `jsonencode()`, or copy JSON from the UI, key ordering may differ from what the provider serializes, causing perpetual diff. Use `jsonencode()` consistently everywhere.

### 9. `source` field — don't set it manually
If you omit `source`, the provider sets it to `<endpoint>/dashboard`. If you set it explicitly and it doesn't match what the API returns, you'll get drift. Either always omit it, or always set it to the exact value the API returns.

### 10. Empty/non-JSON update response (issue #95, open)
Some SigNoz API versions return an empty body on successful update. The provider interprets this as an error. Workaround: upgrade to latest provider version or check if a fix is merged.

### 11. No support for channels, pipelines, or collector config
The provider only manages `alert` and `dashboard` resources. There is no Terraform support for: notification channels, saved views, trace/logs pipelines, OTEL collector configuration, or SigNoz user management.

---

## CI/CD Patterns

### GitHub Actions

```yaml
- name: Terraform Plan
  env:
    SIGNOZ_ACCESS_TOKEN: ${{ secrets.SIGNOZ_ACCESS_TOKEN }}
    SIGNOZ_ENDPOINT: ${{ secrets.SIGNOZ_ENDPOINT }}
  run: |
    terraform init
    terraform plan -out=tfplan

- name: Terraform Apply
  if: github.ref == 'refs/heads/main'
  env:
    SIGNOZ_ACCESS_TOKEN: ${{ secrets.SIGNOZ_ACCESS_TOKEN }}
    SIGNOZ_ENDPOINT: ${{ secrets.SIGNOZ_ENDPOINT }}
  run: terraform apply tfplan
```

### Infisical Injection (for this project)

```bash
infisical run --env=prod -- terraform apply
```

Ensure `SIGNOZ_ACCESS_TOKEN` and `SIGNOZ_ENDPOINT` are in the Infisical `prod` environment.
