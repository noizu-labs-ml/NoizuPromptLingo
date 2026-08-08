# Permission Scope Picker

| Field | Value |
|-------|-------|
| **ID** | `permission-scope-picker` |
| **Category** | Domain-Specific |
| **Used In** | 15-admin-mcp-custom-scopes, 19-project-detail, 45-org-settings |

## Description

The MCP custom-scope tool-tree picker and its close sibling, the org custom-role editor — both are named-bundle-of-granular-permissions editors over a tree/checklist of tools or resource permissions. Platform admins curate global MCP scope presets (15) and org role definitions (45); a project admin then applies a preset to a specific project (19).

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Preset/role selector — applies an existing bundle (Applied MCP Scope Selector on Project Detail) |
| **Expanded** | Full tool-tree / permission checklist editor with name and description fields |

## Props / Configuration

- `mode` — `apply` \| `edit`
- `tree` — the tool/permission tree being selected from or edited
- `presetName` / `presetDescription`

## Interactions

- Edit mode: admin checks/unchecks tools or permissions in the tree and saves → the named preset/role becomes selectable wherever this picker is used in `apply` mode
- Apply mode: a project or org admin selects a saved preset/role → it takes effect immediately, updating the scoped tool surface or member's permissions
- Before editing a widely-used preset, an admin can inspect its usage impact via an adjacent Detail Drawer
