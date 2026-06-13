# Global Sidebar

| Field | Value |
|-------|-------|
| **ID** | `global-sidebar` |
| **Category** | Navigation & Layout |
| **Used In** | 01-Script List, 04-Prompt Library, 06-Agent List, 08-Run List, 11-Rubric List, 13-Persona List, 16-Review Queue, 18-Dataset List, 20-Flagged Captures Library, 22-OTel Span Search, 24-Organization Settings, 25-Schedule List, 29-Custom Dashboard Builder |

## Description

Persistent left sidebar providing primary navigation across all top-level sections. Shows section icons, labels, and badge counts (e.g., review queue pending count). Includes organization switcher and settings access.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Icons only (collapsed) |
| **Expanded** | Icons + labels (full width) |

## Props / Configuration

- `sections` — Navigation items with icon, label, path, badge count
- `activeSection` — Currently active section (highlighted)
- `orgSwitcher` — Organization selector at top
- `collapsed` — Whether sidebar is in icon-only mode
- `badgeCounts` — Dynamic counts (review queue, pending runs, etc.)

## Interactions

- Click section to navigate
- Toggle collapse/expand
- Switch organizations via org switcher
- Badge counts update in real time (review queue)
