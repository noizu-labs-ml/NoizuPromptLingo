# Prompt Version Timeline

| Field | Value |
|-------|-------|
| **ID** | `prompt-timeline` |
| **Type** | Primary |
| **Category** | Prompt Archival & Versioning |
| **User Stories** | US-086, US-087, US-090 |

## Description

Chronological timeline of all prompt versions for an agent with inline diffs, annotations, eval score overlays, and one-click restore to any previous version.

## Key Components

- **Version timeline** — Chronological list of all versions with timestamps
- **Expandable full text** — Click to see full prompt text for any version
- **Diff highlights** — Visual diff showing what changed between versions
- **Eval score annotations** — Quality scores overlaid on timeline entries
- **Restore button** — One-click restore to any previous version
- **Filter by change type** — Filter by major/minor changes, author
- **Keyboard nav** — Arrow keys to navigate timeline

## Interactions

- Scroll through version history
- Expand any version to see full text
- Click between versions to see diff
- Restore to any version with one click (creates new version)
- View eval scores to correlate changes with quality

## Navigation

- Accessible from: Agent detail, Prompt management nav
- Links to: Prompt Comparison, Prompt Annotations, Prompt Audit Trail
