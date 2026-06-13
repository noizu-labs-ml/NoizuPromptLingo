# Breadcrumb Trail

| Field | Value |
|-------|-------|
| **ID** | `breadcrumb-trail` |
| **Category** | Navigation & Layout |
| **Used In** | S05 Canon Entry Detail, S06 Knowledge Graph, S09 Generation Studio, S12 Settings |

## Description

Hierarchical breadcrumb bar rendered below the top header, showing the user's current location within the app hierarchy (Universe > Section > Entry or Sub-section). Each segment is a clickable link except the terminal node, which is plain text representing the current page.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single-line horizontal strip; segments separated by `/` or `›` chevron |

## Props / Configuration

- `segments` — Ordered array of `{ label: string, href?: string }` objects; last item with no `href` is the current page
- `maxVisible` — Max segments to show before collapsing middle segments into `…` (default: `4`)
- `separator` — Separator character or icon between segments (default: `›`)
- `className` — Optional additional CSS class for layout overrides

## Interactions

- Clicking any segment except the last navigates to its `href`
- When segments are collapsed, clicking `…` expands the full trail in-place
- On mobile viewports, only the immediate parent segment and current page are shown; full trail accessible via the `…` expander
- Breadcrumb updates without full page reload when navigating between detail views in a split-panel layout
