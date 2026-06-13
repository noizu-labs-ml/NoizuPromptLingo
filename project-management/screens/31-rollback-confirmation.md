# Rollback Confirmation Modal

| Field | Value |
|-------|-------|
| **ID** | `rollback-confirmation` |
| **Type** | Modal |
| **Category** | CI/CD & Deployments |
| **User Stories** | US-043 |

## Description

Confirmation dialog for rollback operations showing current vs target version, affected services, impact assessment, and mandatory reason field. Creates an audit record.

## Key Components

- **Version comparison** — Current version → target version side-by-side
- **Affected services list** — Which services will be rolled back
- **Impact assessment** — AI-generated assessment of rollback impact
- **Reason field** — Mandatory explanation for the rollback
- **Confirm rollback button** — Execute rollback (requires confirmation)
- **Audit note** — Automatic audit log entry with all context

## Interactions

- Review version diff and impact before confirming
- Provide mandatory reason for rollback
- Confirm executes the rollback operation
- Cancel returns to previous screen
- Post-rollback notification sent to team

## Navigation

- Triggered from: Environment Dashboard, Pipeline Status, Incident detail
- Links to: Environment Dashboard (post-rollback), Deploy Changelog
