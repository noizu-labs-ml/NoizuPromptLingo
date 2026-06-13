# Version History Panel

| Field | Value |
|-------|-------|
| **ID** | `version-history-panel` |
| **Category** | Navigation & Layout |
| **Used In** | 01-Fighter Studio |

## Description

Side panel listing saved graph versions with timestamps, labels, and rank-at-save. Supports restore, visual diff overlay (green=added, red=removed, yellow=moved), and branch-to-new actions.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Collapsible side panel showing version list with timestamps and labels |
| **Expanded** | Full panel with diff preview rendered on graph canvas |

## Props / Configuration

- `versions` — Snapshot list with timestamps, labels, and rank-at-save metadata (up to 50)
- `currentVersion` — Active version number
- `maxSnapshots` — Retention limit for stored snapshots

## Interactions

- Browse version list sorted by timestamp
- Restore a previous version to the active canvas
- View visual diff between any two versions (green=added, red=removed, yellow=moved)
- Create a named snapshot of the current graph state
- Branch a version into a new fighter build
