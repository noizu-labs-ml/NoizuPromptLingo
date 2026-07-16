# Project Detail

| Field | Value |
|-------|-------|
| **ID** | `project-detail` |
| **Type** | Primary |
| **Category** | Core Work |
| **User Stories** | US-050, US-088 |

## Description

Single-project workspace at `/app/[orgId]/projects/[projectId]` showing project metadata, applied MCP custom scope, and the sessions/tickets scoped to it. Falls back to a read-only presentation when the project is archived.

## Key Components

- **Project Header Card** — name, description, status
- **Applied MCP Scope Selector** — assigns a global custom-scope preset to this project (US-050)
- **Archived Read-Only Banner** — indicates and enforces the read-only fallback state (US-088)
- **Scoped Sessions/Tickets Summary** — linked-entity counts and shortcuts

## Interactions

- User selects a preset in the Applied MCP Scope Selector → the project's MCP tool surface updates (US-050)
- If the project is archived, all mutating controls disable and the Archived Read-Only Banner renders (US-088)

## Navigation

- Accessible from: Projects List (18)
- Links to: Sessions List (20), Tickets List (25), Admin: MCP Custom Scopes (15) (preset source)
