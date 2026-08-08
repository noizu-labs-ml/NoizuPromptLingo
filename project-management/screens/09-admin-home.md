# Admin Home

| Field | Value |
|-------|-------|
| **ID** | `admin-home` |
| **Type** | Dashboard |
| **Category** | Platform Admin |
| **User Stories** | US-059 |

## Description

Landing dashboard for platform administrators at `/app/admin`, aggregating cross-org health signals and surfacing items needing admin attention, including the MCP overview review queue.

## Key Components

- **Platform Health Summary Cards** — org/user/session counts and status
- **MCP Overview Queue Widget** — pending items needing admin review (US-059)
- **Admin Nav Sidebar** — links into Users, Organizations, Authz, GitHub, LLM Models, Custom Scopes, Media Providers
- **Recent Admin Activity Feed** — audit trail of recent admin actions

## Interactions

- Admin clicks an MCP Overview Queue Widget item → opens the item's review detail inline or routes to Admin: Authz (12) (US-059)
- Admin clicks an Admin Nav Sidebar link → routes to the corresponding admin sub-screen

## Navigation

- Accessible from: app-shell admin entry (visible only to platform admins)
- Links to: Admin: Users (10), Admin: Organizations (11), Admin: Authz (12), Admin: GitHub Integration (13), Admin: LLM Model Catalog (14), Admin: MCP Custom Scopes (15), Admin: Media Providers (16)
