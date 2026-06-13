# Version Timeline

| Field | Value |
|-------|-------|
| **ID** | `version-timeline` |
| **Category** | Forms |
| **Used In** | S05 Canon Entry Detail (Version History tab) |

## Description

Vertical chronological list of version history entries for a single canon entry. Each row shows a version number, timestamp, author avatar, and a short change summary. Supports diff preview on hover and a restore action to roll back to a specific version.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Condensed rows with timestamp, author initial, and summary only; used in a sidebar panel |
| **Expanded** | Full rows with avatar, relative + absolute timestamp, change summary, and inline action buttons |

## Props / Configuration

- `versions` — Array of `{ versionId, versionNumber, createdAt, author, changeSummary, diffUrl? }` objects, ordered newest-first
- `currentVersionId` — ID of the version currently in view; highlighted in the list
- `onVersionSelect` — Callback fired with `versionId` when a version row is clicked (loads that version in the detail view)
- `onRestore` — Callback fired with `versionId` when the restore button is confirmed
- `canRestore` — Boolean; controls restore button visibility (owners and editors only)
- `loading` — Boolean; shows skeleton rows while version history is being fetched

## Interactions

- Each version row is clickable; clicking loads that version's content in the parent detail view for read-only preview
- The currently viewed version row is highlighted with a left-border accent
- "Restore" button appears on hover or focus of any non-current, non-current version row; clicking opens a confirmation dialog before firing `onRestore`
- If `diffUrl` is present, hovering the row shows a diff summary tooltip with added/removed line counts
- Auto-saves are grouped under the same version number with a "(auto-saved)" label; only the latest auto-save in a group is expandable
- Infinite scroll loads earlier versions as the user scrolls down the timeline
