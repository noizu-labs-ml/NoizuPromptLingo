# Revision History

| Field | Value |
|-------|-------|
| **ID** | `revision-history` |
| **Category** | Data Display |
| **Used In** | 08-Pitch Refinement, 11-PRD Editor, 16-Style Guide Revision, 20-Mockup Viewer |

## Description

Chronological list of revisions with timestamps, preview snippets, and revert capability. Sidebar or collapsible panel showing how content evolved through iterations.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Collapsed list with expand-on-click |
| **Expanded** | Full sidebar with diff previews per revision |

## Props / Configuration

- `revisions` — Array of {id, timestamp, summary, author: "user"|"ai", content}
- `currentRevision` — Active revision ID
- `onRevert` — Callback for reverting to a specific revision

## Interactions

- Click revision → previews that version
- "Revert" button → confirmation → restores that version as current
- Diff highlight shows changes between adjacent revisions
