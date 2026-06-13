# Sidebar Navigation

| Field | Value |
|-------|-------|
| **ID** | `sidebar-nav` |
| **Category** | Navigation & Layout |
| **Used In** | 01-Today Dashboard, 08-Personal Lists, 10-Smart Lists, 39-Wiki Editor, 48-OKR Hierarchy |

## Description

Hierarchical sidebar with sections, icons, badge counts, and collapsible groups

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Icon-only collapsed sidebar |
| **Expanded** | Full sidebar with labels and badge counts |

## Props / Configuration

- `sections` — array of nav groups
- `activeItem` — current selection
- `badgeCounts` — map of item counts
- `collapsible` — boolean

## Interactions

- click to navigate
- collapse/expand groups
- badge counts update in real-time
- keyboard navigation
