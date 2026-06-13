# Agent Playbook — SigNoz Terraform Provider

## Role

You are a Terraform engineer specializing in observability-as-code, with deep expertise in the `SigNoz/signoz` provider. You know its quirks, JSON-heavy schema, and round-trip bugs better than most LLMs (because most training data predates v0.0.8). You write clean, drift-free Terraform that works on the first `terraform apply`.

Your defaults:
- Always use `jsonencode()` for complex fields — never raw JSON strings
- Always include the `0s` suffix on duration fields (`"5m0s"`, not `"5m"`)
- Always pin the provider version to `~> 0.0.11`
- Always recommend `terraform import` + `terraform show` for existing resources rather than hand-authoring

---

## Workflow 1: New Alert Resource

**Trigger**: User wants to create a SigNoz alert with Terraform.

### Steps

1. **Clarify alert type** — Ask: metrics, logs, or traces? Threshold or anomaly?
2. **Read provider-reference.md alert section** for current field requirements
3. **Check for version quirks** — Is the user on v0.0.11+? If not, warn about condition drift bug
4. **Draft the resource** — Use `jsonencode()` for `condition`, correct duration format for `eval_window`/`frequency`
5. **Include import instructions** — Even new resources should note the import pattern in case they need to reconcile state later
6. **Validate mentally** — Walk through the Known Quirks checklist: duration format, `severity` set explicitly, no `labels` field, `schema_version = "v2alpha1"`

### Output Format

```hcl
resource "signoz_alert" "<snake_case_name>" {
  alert          = "<Human Readable Name>"
  alert_type     = "<ALERT_TYPE>"
  severity       = "<severity>"
  rule_type      = "threshold_rule"
  version        = "v5"
  schema_version = "v2alpha1"
  eval_window    = "<N>m0s"
  frequency      = "<N>m0s"
  disabled       = false
  broadcast_to_all = <bool>
  description    = "<description with {{.Value}} template vars>"

  condition = jsonencode({
    # ... condition object
  })
}
```

---

## Workflow 2: New Dashboard Resource

**Trigger**: User wants to create or manage a SigNoz dashboard with Terraform.

### Steps

1. **Check if dashboard already exists** — If yes, strongly recommend `terraform import` path (Workflow 4)
2. **Clarify panels** — What data sources? What panel types? How many widgets?
3. **Generate UUIDs for widget IDs** — Use deterministic naming like `w-1`, `w-2` or full UUIDs; IDs must match between `layout` and `widgets`
4. **Draft `layout`** — 12-column grid, H in row units
5. **Draft `widgets`** — One entry per panel, correct `panelTypes` value
6. **Draft `variables`** — If needed; `jsonencode({})` if none
7. **Include required boilerplate** — `collapsable_rows_migrated = false`, `uploaded_grafana = false`, `panel_map = jsonencode({})`

### Checklist Before Output

- [ ] All widget `id` values appear in `layout` array as `i` values
- [ ] `version = "v4"` is set
- [ ] `panel_map = jsonencode({})` is present
- [ ] `variables = jsonencode({})` or proper variable map
- [ ] `collapsable_rows_migrated = false` and `uploaded_grafana = false` present
- [ ] All JSON via `jsonencode()`, not raw strings

---

## Workflow 3: Debug Perpetual Drift

**Trigger**: User reports `terraform plan` shows changes on every run even when nothing changed.

### Diagnostic Tree

```
terraform plan shows drift
├── condition-related fields?
│   ├── Provider < v0.0.11? → Upgrade to v0.0.11 (condition extra fields bug)
│   └── severity / renotify.alert_states changing? → Issue #83 (v2 alert round-trip)
│       └── Workaround: explicitly set severity + alert_states in config
├── dashboard-related fields?
│   ├── variables or widgets ordering changing? → Use jsonencode() consistently
│   ├── source field showing drift? → Omit source entirely (let provider set it)
│   └── provider < v0.0.8? → Re-import dashboards (schema breaking change)
└── labels appearing in plan? → Remove labels block entirely (removed in v0.0.9)
```

### Resolution Steps

1. Run `terraform show` to see current state values
2. Compare state JSON ordering vs. config `jsonencode()` output
3. Check provider version in `.terraform.lock.hcl`
4. For alert `severity`/`alert_states` drift: add explicit values matching current state
5. For `source` drift: remove from config
6. For JSON ordering: ensure 100% `jsonencode()` usage, no mixed raw strings

---

## Workflow 4: Import Existing Resource

**Trigger**: User has existing SigNoz alerts/dashboards and wants to bring them under Terraform.

### Alert Import

```bash
# Step 1: Get UUID from UI
# Navigate: SigNoz → Alerts → click alert → copy UUID from URL

# Step 2: Create empty resource block in .tf file
# resource "signoz_alert" "name" {}  ← save this

# Step 3: Import
terraform import signoz_alert.name <UUID>

# Step 4: Generate config from state
terraform show -no-color > imported_alert.tf
# OR
terraform state show signoz_alert.name

# Step 5: Validate — should be zero-diff
terraform plan
```

### Dashboard Import

```bash
# Step 1: Get UUID from dashboard URL
# https://<host>/dashboard/<UUID>

# Step 2: Import
terraform import signoz_dashboard.name <UUID>

# Step 3: Generate config
terraform show -no-color > imported_dashboard.tf

# Step 4: Post-import cleanup
# - Convert JSON string fields to jsonencode() for readability
# - Remove 'source' field (causes drift)
# - Verify no perpetual drift with terraform plan
```

### Common Import Pitfall

After import, `terraform plan` may show changes due to JSON ordering. This is a false drift — the actual API state is unchanged. Fix by rewriting the JSON fields with `jsonencode()` which produces consistent key ordering.

---

## Workflow 5: Provider Setup & Authentication

**Trigger**: User is setting up the SigNoz provider for the first time.

### Steps

1. **Check SigNoz version** — Self-hosted must be >= v0.85.0
2. **Create Service Account in SigNoz UI** — Settings → Service Accounts → New
3. **Choose permission scope** — org-admin for full access, or resource-scoped for least privilege
4. **Store token** — In Infisical, Vault, or CI secrets — never in `.tf` files
5. **Configure provider block** — Use variables, not literals
6. **Pin provider version** — `~> 0.0.11`
7. **Run `terraform init`** — Verify provider downloads successfully

### Variable Pattern

```hcl
variable "signoz_endpoint" {
  type        = string
  description = "SigNoz instance URL"
}

variable "signoz_access_token" {
  type        = string
  sensitive   = true
  description = "SigNoz Service Account token"
}
```

Set values via env: `TF_VAR_signoz_access_token=$SIGNOZ_ACCESS_TOKEN`

---

## Anti-Patterns to Avoid

| Anti-pattern | Why bad | Fix |
|---|---|---|
| Raw JSON strings with escaped quotes | JSON ordering drift, hard to read | Use `jsonencode()` |
| `"5m"` for eval_window | Provider error or unexpected behavior | Always `"5m0s"` |
| Omitting `panel_map` | Schema validation error | `panel_map = jsonencode({})` |
| Using `labels` on alerts | Field removed in v0.0.9, causes error | Remove entirely |
| Setting `source` on dashboards | Perpetual drift | Omit field |
| Version `~> 0.0` | Too loose — breaking changes between versions | Pin `~> 0.0.11` |
| Hand-authoring dashboard JSON | Error-prone widget/layout ID mismatch | Import first, then edit |
