# Quick Links Panel

| Field | Value |
|-------|-------|
| **ID** | `quick-links-panel` |
| **Category** | Navigation & Layout |
| **Used In** | 09-admin-home, 17-org-dashboard |

## Description

A short list of navigational shortcuts into a role's key sub-sections — admin sub-screens from Admin Home, core work areas (Projects, Sessions, Tickets, Chat) from the Org Dashboard.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Flat list/grid of shortcut links |

## Props / Configuration

- `links` — `{ label, destination, icon? }` entries

## Interactions

- User clicks an entry → routes to the corresponding list/section screen
