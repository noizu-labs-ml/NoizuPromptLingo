# Artifact Detail (versioned revisions)

| Field | Value |
|-------|-------|
| **ID** | `artifact-detail` |
| **Type** | Primary |
| **Category** | Core Work |
| **User Stories** | None — supporting detail screen for artifacts surfaced via Session Detail (US-002, screen 21) and Artifacts List (31) |

## Description

Single artifact view at `/app/[orgId]/artifacts/[id]` showing an artifact's current content and its full version history of revisions.

## Key Components

- **Artifact Content Viewer** — renders the current revision's content
- **Revision History List** — chronological list of prior versions
- **Version Diff Toggle** — compares two selected revisions
- **Revert to Revision Button** — restores a prior version as the current one

## Interactions

- User selects two entries in the Revision History List and enables the Version Diff Toggle → inline diff renders
- User clicks Revert to Revision Button on a past entry → that version becomes current, recorded as a new revision

## Navigation

- Accessible from: Artifacts List (31), Session Detail (21)
- Links to: none (terminal detail screen)
