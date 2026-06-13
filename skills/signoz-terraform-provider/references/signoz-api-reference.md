# SigNoz REST API Reference

> **Training data gap**: The SigNoz API spans v1–v5 endpoints. Most LLM training data only covers v1 alerts/dashboards. Always verify against the [OpenAPI spec](https://github.com/SigNoz/signoz/blob/main/docs/api/openapi.yml).

---

## Authentication

All API requests use a single header:

```
SIGNOZ-API-KEY: <token>
```

Tokens are **Service Account API Keys**: Settings → Service Accounts → Keys tab.

```bash
# Verify a token is valid
curl "$SIGNOZ_ENDPOINT/api/v1/service_accounts/me" \
  -H "SIGNOZ-API-KEY: $SIGNOZ_TOKEN"
```

### Token Roles

| Role | Alert CRUD | Dashboard CRUD | Channel/User Admin |
|------|-----------|----------------|-------------------|
| Admin (`signoz-admin`) | full | full | full |
| Editor (`signoz-editor`) | full | full | none |
| Viewer (`signoz-viewer`) | read-only | read-only | none |

A service account inherits the union of all assigned roles.

---

## Env Vars in This Project

Tokens for this project belong in `.envrc.dc` under the `signoz` section (currently empty):

```yaml
# .envrc.dc — signoz section
dc_yaml --no-bump signoz cf --layer secrets <<'YAML'
endpoint: https://signoz.greatnonprofits.org
admin_token: <SIGNOZ_ADMIN_TOKEN>
editor_token: <SIGNOZ_EDITOR_TOKEN>
viewer_token: <SIGNOZ_VIEWER_TOKEN>
YAML
```

Token selection guide:
- **Terraform provider** → `editor_token` (least privilege for alert/dashboard CRUD)
- **Read-only CI checks** → `viewer_token`
- **Channel/user management** → `admin_token`

Access via `dc get signoz.editor_token` or set env vars `SIGNOZ_EDITOR_TOKEN` etc.

---

## API Versions

| Version | Scope |
|---------|-------|
| `v1` | Original: alerts (rules), dashboards, channels, downtime, auth |
| `v2` | Extended: rules with history, ingestion keys, metrics, infra monitoring, users |
| `v3` / `v4` | Trace waterfall |
| `v5` | Unified query API (data plane) |

The Terraform provider uses **v1** (`/api/v1/rules`, `/api/v1/dashboards`). The SigNoz UI uses v2 and v5.

---

## Alerts

### v1 (Terraform provider uses these)

| Method | Path | Min Role |
|--------|------|----------|
| GET | `/api/v1/rules` | Viewer |
| POST | `/api/v1/rules` | Editor |
| GET | `/api/v1/rules/{id}` | Viewer |
| PUT | `/api/v1/rules/{id}` | Editor |
| DELETE | `/api/v1/rules/{id}` | Editor |

Response envelope:
```json
{ "status": "success", "data": { ...alert... }, "error": "", "errorType": "" }
```

### v2 (richer — history, patch, test)

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v2/rules` | List |
| POST | `/api/v2/rules` | Create |
| GET | `/api/v2/rules/{id}` | Get |
| PUT | `/api/v2/rules/{id}` | Full replace |
| PATCH | `/api/v2/rules/{id}` | Partial update |
| DELETE | `/api/v2/rules/{id}` | Delete |
| POST | `/api/v2/rules/test` | Test without saving |
| GET | `/api/v2/rules/{id}/history/timeline` | State change history |
| GET | `/api/v2/rules/{id}/history/overall_status` | Firing history summary |
| GET | `/api/v2/rules/{id}/history/stats` | Aggregated stats |
| GET | `/api/v2/rules/{id}/history/top_contributors` | Top contributing series |

```bash
# List alerts
curl "$SIGNOZ_ENDPOINT/api/v2/rules" -H "SIGNOZ-API-KEY: $VIEWER_TOKEN"

# Test an alert rule without creating it
curl -X POST "$SIGNOZ_ENDPOINT/api/v2/rules/test" \
  -H "SIGNOZ-API-KEY: $EDITOR_TOKEN" \
  -H "Content-Type: application/json" -d @rule.json

# Get alert firing history
curl "$SIGNOZ_ENDPOINT/api/v2/rules/$ID/history/timeline" \
  -H "SIGNOZ-API-KEY: $VIEWER_TOKEN"
```

---

## Dashboards

### v1

| Method | Path | Min Role |
|--------|------|----------|
| GET | `/api/v1/dashboards` | Viewer |
| POST | `/api/v1/dashboards` | Editor |
| GET | `/api/v1/dashboards/{id}` | Viewer |
| PUT | `/api/v1/dashboards/{id}` | Editor |
| DELETE | `/api/v1/dashboards/{id}` | Editor |

### v2

| Method | Path | Notes |
|--------|------|-------|
| POST | `/api/v2/dashboards` | Create (newer schema) |
| GET | `/api/v2/dashboards/{id}` | Get by UUID |

### Public Dashboard Sharing

| Method | Path | Notes |
|--------|------|-------|
| POST | `/api/v1/dashboards/{id}/public` | Enable public sharing (Admin) |
| GET | `/api/v1/dashboards/{id}/public` | Get share config |
| PUT | `/api/v1/dashboards/{id}/public` | Update |
| DELETE | `/api/v1/dashboards/{id}/public` | Disable |
| GET | `/api/v1/public/dashboards/{id}` | Read public (no auth required) |

```bash
# Export dashboard for Terraform import
curl "$SIGNOZ_ENDPOINT/api/v1/dashboards/$UUID" \
  -H "SIGNOZ-API-KEY: $VIEWER_TOKEN" | jq .data
```

---

## Data Query API (v5)

Primary data plane used by all panels.

| Method | Path | Notes |
|--------|------|-------|
| POST | `/api/v5/query_range` | Query metrics/logs/traces |
| POST | `/api/v5/substitute_vars` | Resolve template variables |

### Query Range Payload

```json
{
  "start": 1748390400000,
  "end":   1748476800000,
  "step":  60,
  "compositeQuery": {
    "queryType": "builder",
    "panelType": "graph",
    "builder": {
      "queryData": [{
        "dataSource": "metrics",
        "queryName": "A",
        "aggregateOperator": "rate",
        "aggregateAttribute": {
          "key": "http_requests_total",
          "dataType": "float64",
          "type": "Counter",
          "isColumn": false
        },
        "filters": { "op": "AND", "items": [] },
        "groupBy": [],
        "legend": "{{service_name}}"
      }],
      "queryFormulas": []
    }
  }
}
```

**Times are Unix milliseconds** (not seconds). `step` is seconds.

```bash
NOW_MS=$(python3 -c "import time; print(int(time.time()*1000))")
HOUR_AGO=$((NOW_MS - 3600000))

curl -X POST "$SIGNOZ_ENDPOINT/api/v5/query_range" \
  -H "SIGNOZ-API-KEY: $VIEWER_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"start\":$HOUR_AGO,\"end\":$NOW_MS,\"step\":60,\"compositeQuery\":{\"queryType\":\"builder\",\"panelType\":\"graph\",\"builder\":{\"queryData\":[{\"dataSource\":\"metrics\",\"queryName\":\"A\",\"aggregateOperator\":\"sum\",\"aggregateAttribute\":{\"key\":\"http_requests_total\",\"dataType\":\"float64\",\"type\":\"Counter\",\"isColumn\":false},\"filters\":{\"op\":\"AND\",\"items\":[]}}]}}}"
```

---

## Metrics API (v2)

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v2/metrics` | List all metrics |
| GET | `/api/v2/metrics/{name}/metadata` | Metric metadata |
| POST | `/api/v2/metrics/{name}/metadata` | Update metadata |
| GET | `/api/v2/metrics/{name}/attributes` | Attribute keys |
| GET | `/api/v2/metrics/{name}/alerts` | Alerts using this metric |
| GET | `/api/v2/metrics/{name}/dashboards` | Dashboards using this metric |
| POST | `/api/v2/metrics/inspect` | Inspect raw metric data |
| POST | `/api/v2/metrics/stats` | Aggregated stats |

---

## Notification Channels

Not managed by the Terraform provider — requires Admin role.

| Method | Path |
|--------|------|
| GET | `/api/v1/channels` |
| POST | `/api/v1/channels` |
| GET | `/api/v1/channels/{id}` |
| PUT | `/api/v1/channels/{id}` |
| DELETE | `/api/v1/channels/{id}` |
| POST | `/api/v1/channels/test` |

---

## Downtime Schedules

| Method | Path | Min Role |
|--------|------|----------|
| GET | `/api/v1/downtime_schedules` | Viewer |
| POST | `/api/v1/downtime_schedules` | Editor |
| GET | `/api/v1/downtime_schedules/{id}` | Viewer |
| PUT | `/api/v1/downtime_schedules/{id}` | Editor |
| DELETE | `/api/v1/downtime_schedules/{id}` | Editor |

---

## Field Keys / Values (logs, traces)

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v1/fields/keys?dataSource=logs` | Available field keys |
| GET | `/api/v1/fields/values?dataSource=logs&key=severity_text` | Values for a key |

---

## Ingestion Keys (v2, Admin only)

Ingestion keys are **write-only** (send telemetry), separate from API keys (read/manage).

| Method | Path |
|--------|------|
| GET | `/api/v2/gateway/ingestion_keys` |
| POST | `/api/v2/gateway/ingestion_keys` |
| PATCH | `/api/v2/gateway/ingestion_keys/{keyId}` |
| DELETE | `/api/v2/gateway/ingestion_keys/{keyId}` |
| POST | `/api/v2/gateway/ingestion_keys/{keyId}/limits` |

---

## Infrastructure Monitoring (v2)

All `POST` with filter/pagination body:

```
POST /api/v2/infra_monitoring/hosts
POST /api/v2/infra_monitoring/nodes
POST /api/v2/infra_monitoring/pods
POST /api/v2/infra_monitoring/clusters
POST /api/v2/infra_monitoring/namespaces
POST /api/v2/infra_monitoring/deployments
POST /api/v2/infra_monitoring/daemonsets
POST /api/v2/infra_monitoring/statefulsets
POST /api/v2/infra_monitoring/pvcs
POST /api/v2/infra_monitoring/jobs
```

---

## Trace Waterfall

| Method | Path | Notes |
|--------|------|-------|
| POST | `/api/v3/traces/{traceID}/waterfall` | v3 format |
| POST | `/api/v4/traces/{traceID}/waterfall` | v4 format (prefer this) |

---

## IAM / User Management (Admin)

| Method | Path |
|--------|------|
| GET | `/api/v2/users` |
| GET | `/api/v2/users/me` |
| GET | `/api/v2/users/{id}/roles` |
| POST | `/api/v2/users/{id}/roles` |
| DELETE | `/api/v2/users/{id}/roles/{roleId}` |
| GET | `/api/v1/roles` |
| POST | `/api/v1/invite` |
| POST | `/api/v1/invite/bulk` |

---

## Health / Readiness

```bash
GET /api/v2/livez    # liveness probe
GET /api/v2/readyz   # readiness probe
GET /api/v2/healthz  # full health
```

---

## Authorization Check

```bash
POST /api/v1/authz/check
```

Body: `{ "subject": "service-account-id", "permission": "create", "resource": "rules" }`

---

## API Quirks

1. **Check `status` not HTTP code** — All v1 responses envelope as `{"status":"success|error"}`. A 200 with `"status":"error"` is a real error.

2. **v2 rules for scripting** — Prefer `/api/v2/rules` over v1 when writing automation; it supports PATCH and exposes alert history endpoints.

3. **Times are milliseconds** — `query_range` start/end are Unix ms; `step` is seconds.

4. **Dashboard IDs are UUIDs** — Pull from the UI URL: `https://<host>/dashboard/<UUID>`.

5. **Empty body on successful update** — Some PUT endpoints return 200 with empty body. Treat 2xx as success.

6. **Header spelling** — `SIGNOZ-API-KEY` uses hyphens, not underscores. The env var is `SIGNOZ_ACCESS_TOKEN`; the header is `SIGNOZ-API-KEY`.
