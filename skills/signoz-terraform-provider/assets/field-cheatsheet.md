# SigNoz Terraform Provider — Field Cheatsheet

## Provider Config

| Field | Env Var | Example |
|-------|---------|---------|
| `endpoint` | `SIGNOZ_ENDPOINT` | `https://signoz.example.com` |
| `access_token` | `SIGNOZ_ACCESS_TOKEN` | (Service Account token) |

## `signoz_alert` — All Fields

| Field | Req | Type | Value / Notes |
|-------|-----|------|---------------|
| `alert` | ✓ | string | Display name |
| `alert_type` | ✓ | string | `LOGS_BASED_ALERT` / `METRIC_BASED_ALERT` / `TRACES_BASED_ALERT` / `EXCEPTIONS_BASED_ALERT` / `ANOMALY_DETECTION_ALERT` |
| `severity` | ✓ | string | `critical` / `warning` / `info` |
| `rule_type` | ✓ | string | Always `"threshold_rule"` |
| `version` | ✓ | string | Always `"v5"` |
| `schema_version` | ✓ | string | Always `"v2alpha1"` |
| `condition` | ✓ | string(JSON) | Use `jsonencode({...})` |
| `eval_window` | ✓ | string | `"5m0s"` — **0s suffix required** |
| `frequency` | ✓ | string | `"1m0s"` — **0s suffix required** |
| `description` | — | string | Supports `{{.Value}}`, `{{.EvalWindow}}` |
| `disabled` | — | bool | Default `false` |
| `broadcast_to_all` | — | bool | Notify all channels |
| `notification_settings` | — | object | `renotify`, `group_by`, `use_policy` |
| `labels` | ❌ | — | **REMOVED in v0.0.9 — do not use** |

## `signoz_dashboard` — All Fields

| Field | Req | Type | Value / Notes |
|-------|-----|------|---------------|
| `name` | ✓ | string | Internal slug identifier |
| `title` | ✓ | string | UI display name |
| `description` | ✓ | string | Purpose description |
| `version` | ✓ | string | Always `"v4"` |
| `layout` | ✓ | string(JSON) | Array of grid positions — use `jsonencode([...])` |
| `widgets` | ✓ | string(JSON) | Array of widget configs — use `jsonencode([...])` |
| `variables` | ✓ | string(JSON) | Map of template vars — use `jsonencode({})` if none |
| `collapsable_rows_migrated` | ✓ | bool | Always `false` |
| `uploaded_grafana` | ✓ | bool | Always `false` (unless Grafana import) |
| `panel_map` | — | string(JSON) | Always `jsonencode({})` — **don't omit** |
| `source` | — | string | **Omit** — causes drift if set manually |
| `tags` | — | list(string) | Categorization labels |

## Duration Format Quick Reference

| Human | Terraform Value |
|-------|----------------|
| 1 minute | `"1m0s"` |
| 5 minutes | `"5m0s"` |
| 15 minutes | `"15m0s"` |
| 1 hour | `"1h0m0s"` |
| 24 hours | `"24h0m0s"` |

## Import Commands

```bash
# Alert
terraform import signoz_alert.<name> <uuid-from-ui-url>

# Dashboard
terraform import signoz_dashboard.<name> <uuid-from-ui-url>
```

## Common Drift Causes (Quick Fix)

| Symptom | Fix |
|---------|-----|
| `condition` fields changing | Upgrade to v0.0.11+ |
| `severity` / `alert_states` flipping | Issue #83 — set explicitly in config |
| `source` field changing on dashboard | Omit `source` from config |
| `labels` block error | Remove `labels` entirely |
| Dashboard after upgrade | Re-import after upgrading past v0.0.8 |
| JSON key ordering diff | Use `jsonencode()` everywhere |
