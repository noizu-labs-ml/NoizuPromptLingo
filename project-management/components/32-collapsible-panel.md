# Collapsible Panel

| Field | Value |
|-------|-------|
| **ID** | `collapsible-panel` |
| **Category** | Navigation & Layout |
| **Used In** | 01-Today Dashboard, 05-Inbox, 23-Bug Detail, 27-Pipeline Status, 33-Incident Detail, 39-Wiki Editor |

## Description

Expandable/collapsible content section with header, typically for secondary information

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Header with chevron toggle |
| **Expanded** | Panel with full content visible |

## Props / Configuration

- `title` — string
- `defaultExpanded` — boolean
- `content` — component
- `badge` — optional count/indicator

## Interactions

- click header to toggle
- keyboard Enter/Space to toggle
- animated expand/collapse
