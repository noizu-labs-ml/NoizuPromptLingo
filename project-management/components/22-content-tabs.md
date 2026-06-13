# Content Tabs

| Field | Value |
|-------|-------|
| **ID** | `content-tabs` |
| **Category** | Navigation & Layout |
| **Used In** | 08-Explore Resources, 36-User Profile |

## Description

Horizontal tab bar for switching content views. Shows tab labels with optional counts and active state indicator.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Horizontal tab links |
| **Compact** — Tabs with count badges |

## Props / Configuration

- `tabs` — Array of {id, label, count?}
- `activeTab` — Currently selected tab ID
- `onChange` — Tab switch callback

## Interactions

- Click tab → switch content view; URL updates to reflect tab
