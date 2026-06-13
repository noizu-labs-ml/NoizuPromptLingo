# Runbook Manager

| Field | Value |
|-------|-------|
| **ID** | `runbook-manager` |
| **Type** | Primary |
| **Category** | Documentation & Wiki |
| **User Stories** | US-059 |

## Description

Runbook listing with version control, incident linking (which incidents used this runbook), usage tracking, and executable step support (steps that can trigger automated actions).

## Key Components

- **Runbook list** — All runbooks with title, last updated, usage count
- **Version selector** — Switch between runbook versions
- **Incident links** — Which incidents referenced this runbook
- **Usage count** — How many times the runbook was followed
- **Step-by-step view** — Ordered steps with check-off capability
- **Executable step indicator** — Steps that can trigger automation
- **Edit mode** — Rich editor for runbook content

## Interactions

- Follow runbook step-by-step during incidents
- Check off steps as completed
- Executable steps offer one-click automation
- Track which incidents used which version
- Version runbooks with diff viewing

## Navigation

- Accessible from: Documentation nav, Incident Detail
- Links to: Incident Detail, Wiki, Automation configuration
