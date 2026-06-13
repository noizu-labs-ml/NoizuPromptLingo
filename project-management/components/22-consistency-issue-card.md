# Consistency Issue Card

| Field | Value |
|-------|-------|
| **ID** | `consistency-issue-card` |
| **Category** | Forms |
| **Used In** | S10 Consistency Dashboard, S10 Issue Detail |

## Description

Card component displaying a single consistency issue flagged by the AI consistency engine. Shows severity, issue type category, a plain-language description, a list of affected entry links, and resolution action buttons. Used in both the dashboard list and as an expanded detail view.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Single-row list item with severity badge, type, short description, and affected entry count; used in the dashboard issue list |
| **Expanded** | Full card with complete description, all affected entry links, resolution options, and ignore controls; used in the issue detail panel |

## Props / Configuration

- `issue` — Issue data object: `{ id, severity, type, description, affectedEntries, detectedAt, status, resolution? }`
- `severity` — `critical` | `major` | `minor` | `info`; drives badge color and sort priority
- `affectedEntries` — Array of `{ id, name, type }` entry references
- `onEntryClick` — Callback with entry ID when an affected entry link is clicked
- `onResolve` — Callback with `{ issueId, resolutionType }` when a resolution action is taken
- `onIgnore` — Callback with `issueId` when the issue is dismissed/ignored
- `onExpand` — Callback fired when the compact card is clicked to load the expanded detail
- `resolutionOptions` — Array of available resolution actions (e.g., "Update Entry A", "Update Entry B", "Mark as Intentional")
- `loading` — Boolean; shows a spinner while a resolution action is being applied

## Interactions

- Clicking a compact card fires `onExpand` and loads the expanded view in the right panel of the split layout
- Severity badge color: red (critical), orange (major), yellow (minor), blue (info)
- Affected entry links are clickable and navigate to the entry detail (or open in the right panel)
- Resolution option buttons are rendered as a set of secondary action buttons; selecting one opens a confirmation step then fires `onResolve`
- "Ignore / Mark Intentional" dismisses the issue with an undo toast notification
- Issue cards with `status: resolved` are visually dimmed and moved to a "Resolved" section at the bottom of the dashboard list
