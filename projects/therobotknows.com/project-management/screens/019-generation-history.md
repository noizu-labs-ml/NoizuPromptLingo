# Generation History View

| Field | Value |
|-------|-------|
| **ID** | generation-history |
| **Type** | Primary |
| **Category** | Generation |
| **User Stories** | US-045, US-047, US-048 |

## Description

Chronological list of all generation events for a universe.

## Key Components

- **History List** — Reverse-chronological list (US-045)
- **Entry Details per Job** — Prompt, type, timestamp, status, token cost (US-045)
- **Status Badges** — Promoted, Discarded, Pending (US-045)
- **Detail View Link** — Open full generated draft (US-045)
- **Sources Links** — Link to source entries used (US-045)
- **Restore Button** — Restore discarded draft (US-047)
- **Canon Entry Link** — Link to resulting canon entry if promoted (US-045)
- **Filter/Search** — Search by prompt text, filter by date range (US-045)
- **Pagination** — 20 entries per page (US-045)
- **Cost Summary** — Per-universe token/cost breakdown (US-048)

## Interactions

- Clicking history entry opens detail view
- Discarded drafts can be restored to new draft
- Promoted drafts link to canon entry
- Search filters by prompt text matching
- Date range filters visible time window
- Cost summary shows usage by universe

## Navigation

- Accessible from: Generation Studio (history link), Generation Queue
- Links to: Draft Detail Panel, Canon Entry Detail