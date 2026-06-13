# Workspace Settings

| Field | Value |
|-------|-------|
| **ID** | `workspace-settings` |
| **Type** | Settings |
| **Category** | User Settings |
| **User Stories** | US-021, US-026, US-036, US-050, US-053, US-065, US-077 |

## Description

Workspace-level administration covering methodology defaults, SLA/SLO configuration, agent role management, status page branding, and workflow enforcement rules. Admin-only access.

## Sections

### General
- **Workspace name and branding** — Logo, colors, name
- **Default methodology** — Default project methodology for new projects (US-021)
- **Member management** — Invite, remove, role assignment

### Methodologies
- **Available methodologies** — Enable/disable Scrum, Kanban, Waterfall, custom (US-026)
- **Custom methodology builder** — Define custom workflow states and transitions
- **Default methodology per project type** — Map project types to methodologies

### SLA & SLO
- **SLA definitions** — Per-severity response/resolution time targets (US-036)
- **SLO definitions** — Service-level objective targets (US-050)
- **Escalation policies** — Auto-escalation rules for SLA breaches

### Agent Administration
- **Agent role management** — Define and manage agent roles (US-077)
- **Default agent permissions** — Workspace-wide permission defaults
- **Agent spending limits** — Global budget caps

### Status Page
- **Branding** — Status page appearance customization (US-053)
- **Service catalog** — Define monitored services
- **Subscriber management** — Manage notification subscribers

### Workflows
- **Checklist enforcement** — Workspace-wide enforcement defaults (US-065)
- **Approval chain templates** — Define approval workflows

## Navigation

- Accessible from: Settings nav (admin section)
- Links to: Agent Roles, Checklist Enforcement, SLA Dashboard, Status Page
