# Customer Bug Intake Form

| Field | Value |
|-------|-------|
| **ID** | `customer-bug-intake` |
| **Type** | Primary |
| **Category** | Bug Tracking |
| **User Stories** | US-040 |

## Description

Public-facing embeddable form for client-reported bugs. Branded per-client, includes deduplication, and provides a tracking ID for follow-up. Separate from internal bug creation.

## Key Components

- **Branded form** — Client-specific branding and theming
- **Title input** — Simple bug title
- **Description input** — Guided description with prompts
- **Screenshot upload** — Drag-drop or paste image
- **Severity selector** — Client-facing severity options
- **Confirmation with tracking ID** — Unique ID for client to reference
- **Public status page link** — Link to check bug status

## Interactions

- Client fills form without authentication
- Duplicate detection suggests "is this your issue?" before submission
- Tracking ID issued on submit for follow-up
- Status page link provided for progress monitoring
- Internal team gets notification of new intake

## Navigation

- Accessible from: Embeddable URL, client portal
- Links to: Public bug status page
