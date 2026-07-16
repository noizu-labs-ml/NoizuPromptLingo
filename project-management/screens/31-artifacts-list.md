# Artifacts List

| Field | Value |
|-------|-------|
| **ID** | `artifacts-list` |
| **Type** | Primary |
| **Category** | Core Work |
| **User Stories** | US-002 |

## Description

Org-scoped listing of artifacts at `/app/[orgId]/artifacts`, surfacing the artifacts produced by a session — the concrete outputs a user reviews when resuming their work.

## Key Components

- **Artifact Table** — name, type, owning session, last-revised timestamp
- **Session Filter Chip** — narrows the list to a specific session's artifacts (US-002)
- **Artifact Type Icon** — visual type indicator (doc/code/spec/etc.) per row
- **Create Artifact Button** — records a new artifact against a session

## Interactions

- User filters by session via the Session Filter Chip → table narrows to that session's artifacts (US-002)
- User clicks a row → opens Artifact Detail (32)

## Navigation

- Accessible from: Org Dashboard (17), Session Detail (21)
- Links to: Artifact Detail (32)
