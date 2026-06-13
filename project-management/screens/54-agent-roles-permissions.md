# Agent Roles & Permissions

| Field | Value |
|-------|-------|
| **ID** | `agent-roles-permissions` |
| **Type** | Settings |
| **Category** | Agent Management |
| **User Stories** | US-077 |

## Description

Configure agent roles with granular permissions per resource type (items, deploys, docs, wiki, incidents), scoped to workspace, project, or item level. Includes default role templates.

## Key Components

- **Role list** — All defined agent roles with descriptions
- **Permission matrix** — Resource × action grid (read/write/execute/admin)
- **Scope selector** — Set permission scope (workspace/project/item)
- **Default role templates** — Pre-built roles (viewer, contributor, operator, admin)
- **Audit log link** — Quick-access to agent audit log
- **Immediate effect toggle** — Changes take effect immediately vs next task

## Interactions

- Create custom roles or clone from templates
- Toggle permissions in the matrix
- Scope permissions to specific projects
- Changes take effect immediately (with confirmation)
- View which agents use which roles

## Navigation

- Accessible from: Settings nav, Agent Team Dashboard
- Links to: Agent Audit Log, Agent Team Dashboard
