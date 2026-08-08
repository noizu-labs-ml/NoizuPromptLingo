# Detail Drawer

| Field | Value |
|-------|-------|
| **ID** | `detail-drawer` |
| **Category** | Modals & Overlays |
| **Used In** | 11-admin-organizations, 15-admin-mcp-custom-scopes |

## Description

An edge-anchored panel that surfaces summary or usage detail for a selected row without navigating away from the list — an org's quick-view metadata, or a scope preset's usage-impact breakdown before editing it.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Key metadata fields only |
| **Expanded** | Metadata plus a related list (e.g. orgs/projects applying a preset) |

## Props / Configuration

- `targetId` — the row the drawer is showing detail for
- `content` — metadata / usage fields to render

## Interactions

- User clicks a row → the drawer slides in from the edge with that row's detail, list stays visible underneath
- Closing the drawer (X, backdrop, or Escape) returns focus to the triggering row
