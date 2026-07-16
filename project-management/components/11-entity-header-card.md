# Entity Header Card

| Field | Value |
|-------|-------|
| **ID** | `entity-header-card` |
| **Category** | Cards & Tiles |
| **Used In** | 19-project-detail, 21-session-detail, 33-agent-personas-management |

## Description

The title block atop a single-entity workspace — name, status, and description, with the description/title fields directly editable inline. Used for projects, sessions, and agent personas alike.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Name + status only |
| **Expanded** | Name, status, description, and inline-edit affordance |

## Props / Configuration

- `title` / `status` / `description`
- `editable` — enables inline editing of title/description
- `statusOptions` — when paired with a Selector/Dropdown for status changes

## Interactions

- User edits the title or description inline → change autosaves without a separate save click
- Status changes are delegated to an adjacent Selector/Dropdown or Status Badge, not edited inline here
