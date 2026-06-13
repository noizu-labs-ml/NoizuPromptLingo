# Breadcrumb

| Field | Value |
|-------|-------|
| **ID** | `breadcrumb` |
| **Category** | Navigation & Layout |
| **Used In** | 23-Bug Detail, 33-Incident Detail, 39-Wiki Editor, 48-OKR Hierarchy |

## Description

Hierarchical path indicator showing navigation context with clickable ancestors

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Text breadcrumb with separators |

## Props / Configuration

- `path` — array of {label, href}
- `separator` — string|icon

## Interactions

- click ancestor to navigate up
- truncate with ellipsis for deep paths
