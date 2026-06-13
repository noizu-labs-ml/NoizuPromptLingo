---
name: signoz-terraform-provider
description: >
  Manage SigNoz observability resources as Terraform IaC or via direct REST API.
  Use this skill when the user wants to write, import, update, or debug
  SigNoz alert rules or dashboards via Terraform; call the SigNoz REST API
  directly (query metrics, fetch alert history, manage channels, inspect traces);
  provision SigNoz IaC in a CI/CD pipeline; migrate existing SigNoz config into
  Terraform state; or troubleshoot provider drift and JSON-encoding quirks —
  even if they don't say "Terraform." Also trigger when users mention
  signoz_alert, signoz_dashboard, SIGNOZ-API-KEY, SIGNOZ_ACCESS_TOKEN,
  query_range, api/v5, api/v2/rules, SigNoz Service Account tokens,
  SigNoz ingestion keys, or SigNoz Terraform import.
---

# SigNoz Terraform Provider

Manage SigNoz alerts and dashboards as version-controlled, reviewable Terraform IaC using the `SigNoz/signoz` provider.

## Overview

This skill provides:

- **Provider setup** — Authentication via Service Account tokens, env-var patterns, version pinning
- **Alert management** — Full `signoz_alert` resource reference, all field types, quirks, and round-trip bugs
- **Dashboard management** — `signoz_dashboard` JSON-heavy schema, layout/widget/variable structures
- **Known quirks catalog** — Every documented gotcha from GitHub issues and release notes (this provider is sparse in most LLM training data)
- **Import workflows** — How to bring existing SigNoz resources under Terraform state
- **CI/CD patterns** — Safe Terraform apply in pipelines, secret injection, drift detection

## Core Philosophy

1. **jsonencode() over raw strings** — Every complex field (condition, layout, widgets, variables) is a JSON string. Use `jsonencode()` in HCL so the structure is readable and Terraform can diff it.
2. **Pin the provider version** — The provider is pre-1.0 and has had breaking schema changes between minor versions. Always pin `~> 0.0.11`.
3. **Service Account tokens only** — Use Service Account tokens (not user API keys) for CI. Rotate them on the same schedule as other infra credentials.
4. **Import before you write** — For existing dashboards/alerts, always import first and generate config from state (`terraform show`). Hand-authoring complex widget JSON from scratch is error-prone.
5. **Verify against SigNoz version** — The provider schema (`version: "v5"`, `schema_version: "v2alpha1"`) must match what your SigNoz backend expects. Self-hosted users: stay on >= v0.85.0.

## When to Use This Skill

- **Setting up the provider** — `required_providers` block, auth env vars, provider config
- **Writing alert resources** — `signoz_alert` fields, alert types, condition JSON, notification settings
- **Writing dashboard resources** — `signoz_dashboard` layout/widget/variable JSON structures
- **Debugging perpetual drift** — Provider plan shows changes on every apply despite no config change
- **Importing existing resources** — Capture live SigNoz state into Terraform
- **CI/CD pipeline integration** — Inject `SIGNOZ_ACCESS_TOKEN` safely, run plan/apply in automation
- **Upgrading provider version** — Breaking changes between versions and migration steps
- **Direct REST API calls** — Querying metrics/logs/traces via `api/v5/query_range`, fetching alert history, managing channels, inspecting ingestion keys
- **API key management** — Admin/Editor/Viewer token roles, storing in `.envrc.dc`, selecting right token per operation

> For the full Terraform provider quirks catalog, see [references/provider-reference.md](references/provider-reference.md).
> For the complete REST API reference (all v1–v5 endpoints, roles, query format), see [references/signoz-api-reference.md](references/signoz-api-reference.md).
> For step-by-step alert and dashboard authoring, see [references/agent-playbook.claude-code.md](references/agent-playbook.claude-code.md).
> For a complete worked example, see [references/worked-example-alert-stack.md](references/worked-example-alert-stack.md).

## Provider at a Glance

| Item | Value |
|------|-------|
| Registry source | `SigNoz/signoz` |
| Latest stable | `v0.0.11` (Nov 2025) |
| Terraform minimum | `>= 1.0` |
| SigNoz minimum (self-hosted) | `>= v0.85.0` |
| Resources | `signoz_alert`, `signoz_dashboard` |
| Data sources | `signoz_alert`, `signoz_dashboard` |
| Auth env vars | `SIGNOZ_ACCESS_TOKEN`, `SIGNOZ_ENDPOINT` |

## Quick Start

### 1. Provider Block

```hcl
terraform {
  required_providers {
    signoz = {
      source  = "SigNoz/signoz"
      version = "~> 0.0.11"
    }
  }
  required_version = ">= 1.0"
}

provider "signoz" {
  endpoint     = var.signoz_endpoint     # https://your-signoz.example.com
  access_token = var.signoz_access_token # from env: SIGNOZ_ACCESS_TOKEN
}
```

### 2. Minimal Alert

```hcl
resource "signoz_alert" "high_error_rate" {
  alert         = "High Error Rate"
  alert_type    = "LOGS_BASED_ALERT"
  severity      = "critical"
  rule_type     = "threshold_rule"
  version       = "v5"
  schema_version = "v2alpha1"
  eval_window   = "5m0s"   # NOTE: "0s" suffix required, not "5m"
  frequency     = "1m0s"
  disabled      = false
  broadcast_to_all = true

  condition = jsonencode({
    op               = ">"
    target           = 10
    compositeQuery   = {
      queryType = "builder"
      builderQueries = {
        A = {
          dataSource        = "logs"
          queryName         = "A"
          aggregateOperator = "count"
          filters = { op = "AND", items = [] }
        }
      }
    }
  })

  description = "Error rate exceeded {{.Value}} in the last {{.EvalWindow}}"
}
```

### 3. Import Existing Resource

```bash
# Get the UUID from the SigNoz UI URL:
# https://<host>/alerts/<ALERT-UUID>
terraform import signoz_alert.high_error_rate <ALERT-UUID>
terraform show -no-color > imported.tf
```

## Quick Start Guides

### Writing a New Alert from Scratch
1. Read [references/provider-reference.md](references/provider-reference.md) — alert fields section
2. Copy the minimal alert template above
3. Check the **Known Quirks** section for `eval_window` format and `condition` round-trip issues
4. Run `terraform validate` → `terraform plan` → inspect diff carefully for drift
5. Apply only when plan shows zero unexpected changes

### Importing an Existing Dashboard
1. Get dashboard UUID from UI: `https://<host>/dashboard/<UUID>`
2. Create an empty `signoz_dashboard` resource block
3. `terraform import signoz_dashboard.name <UUID>`
4. `terraform show -no-color > dashboard.tf` — copy output back into resource block
5. `terraform plan` — should show no changes if import was clean

### Debugging Perpetual Drift
1. Check [references/provider-reference.md](references/provider-reference.md) — Known Quirks section
2. Most common causes: `condition` extra fields (upgrade to v0.0.11+), alert `severity` round-trip (issue #83), dashboard `variables` JSON ordering
3. Use `jsonencode()` consistently — avoid raw JSON strings with escaped quotes

### CI/CD Pipeline Setup
1. Create a SigNoz Service Account with org-admin or resource-scoped permissions
2. Store token as `SIGNOZ_ACCESS_TOKEN` in your secrets manager (Infisical, Vault, GitHub Secrets)
3. Inject at runtime — never commit to `.tf` files or state
4. Run `terraform plan` on PR, `terraform apply` on merge to main

## Reference Guide

| Task | Read These |
|------|-----------|
| **Provider config and auth** | `references/provider-reference.md` — Provider Config section |
| **Alert resource fields** | `references/provider-reference.md` — Alert Resource section |
| **Dashboard resource fields** | `references/provider-reference.md` — Dashboard Resource section |
| **Debugging drift** | `references/provider-reference.md` — Known Quirks section |
| **Direct REST API calls** | `references/signoz-api-reference.md` — full endpoint catalog |
| **Token roles (Admin/Editor/Viewer)** | `references/signoz-api-reference.md` — Auth + Token Roles |
| **Querying metrics/logs/traces** | `references/signoz-api-reference.md` — Data Query API (v5) |
| **Alert history / firing timeline** | `references/signoz-api-reference.md` — Alerts v2 section |
| **Worked alert + dashboard example** | `references/worked-example-alert-stack.md` |
| **Agent execution workflows** | `references/agent-playbook.claude-code.md` |

## Related Skills

- **trl-terraform-engineer** — General Terraform patterns, module design, remote state, Terragrunt
- **trl-kubernetes-engineer** — Helm charts and K8s resources that SigNoz runs on
- **trl-threat-modeler** — Threat model for observability infrastructure and token exposure

## Bundled Resources

### References
- [provider-reference.md](references/provider-reference.md) — Complete Terraform provider reference: all fields, quirks, version history, known issues
- [signoz-api-reference.md](references/signoz-api-reference.md) — Full SigNoz REST API: v1–v5 endpoints, token roles, query format, `.envrc.dc` setup
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role + execution workflows for alert and dashboard authoring
- [worked-example-alert-stack.md](references/worked-example-alert-stack.md) — End-to-end example: alert + dashboard + import + CI

### Assets
- [field-cheatsheet.md](assets/field-cheatsheet.md) — Quick-reference table for all fields across both resources
