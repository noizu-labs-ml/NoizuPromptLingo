# ADR Index & Detail

| Field | Value |
|-------|-------|
| **ID** | `adr-index` |
| **Type** | Primary |
| **Category** | Documentation & Wiki |
| **User Stories** | US-058 |

## Description

Architecture Decision Records listing with status filters (proposed, accepted, deprecated, superseded), supersession chains showing decision evolution, and structured template for creating new ADRs.

## Key Components

- **ADR list** — All ADRs with title, status, date, author
- **Status filter** — Filter by proposed/accepted/deprecated/superseded
- **Supersession links** — Visual chain showing which ADRs supersede others
- **Structured template form** — Guided creation: context, decision, consequences
- **Linked items section** — Work items and PRs related to this ADR
- **Search bar** — Full-text search across ADR content

## Interactions

- Filter by status to find active decisions
- Follow supersession chains to see decision evolution
- Create new ADR from structured template
- Link ADRs to implementation work items
- Deprecate/supersede with required link to successor

## Navigation

- Accessible from: Documentation nav, Wiki
- Links to: Wiki pages, Item detail (linked work), Source code
