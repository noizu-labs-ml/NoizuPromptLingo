# Admin: MCP Custom Scopes

| Field | Value |
|-------|-------|
| **ID** | `admin-mcp-custom-scopes` |
| **Type** | Settings |
| **Category** | Platform Admin |
| **User Stories** | US-058 |

## Description

Global MCP custom-scope preset library at `/app/admin/mcp-custom-scopes`, where platform admins curate reusable scope presets that org/project admins can later apply to a project.

## Key Components

- **Scope Preset List** — all global presets with usage counts (US-058)
- **Preset Editor Form** — name, description, included tool/permission set (US-058)
- **Preset Usage Drawer** — which orgs/projects currently apply a given preset

## Interactions

- Admin creates or edits a preset via the Preset Editor Form → saved preset becomes selectable from Project Detail (19) (US-058)
- Admin opens the Preset Usage Drawer to check impact before editing a widely-used preset (US-058)

## Navigation

- Accessible from: Admin Home (09) sidebar
- Links to: Project Detail (19) (where presets are applied)
