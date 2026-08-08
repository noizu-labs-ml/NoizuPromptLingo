# Sessions List

| Field | Value |
|-------|-------|
| **ID** | `sessions-list` |
| **Type** | Primary |
| **Category** | Core Work |
| **User Stories** | US-001, US-004 |

## Description

Org-scoped listing of work sessions at `/app/[orgId]/sessions`, filterable by status, with the entry point for creating a new session scoped to an org/project.

## Key Components

- **Session Table** — status, title, project, last-active timestamp (US-004)
- **Status Filter Chips** — active/paused/completed filters (US-004)
- **Create Session Button** — opens the new-session form (US-001)
- **New Session Modal** — org/project scope picker plus title/description fields (US-001)

## Interactions

- User toggles a Status Filter Chip → the Session Table narrows live (US-004)
- User clicks Create Session Button → New Session Modal collects scope and title, then creates and opens the session (US-001)

## Navigation

- Accessible from: Org Dashboard (17), Project Detail (19)
- Links to: Session Detail (21)
