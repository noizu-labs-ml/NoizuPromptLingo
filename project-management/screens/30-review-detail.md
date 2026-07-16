# Review Detail (overlay annotation)

| Field | Value |
|-------|-------|
| **ID** | `review-detail` |
| **Type** | Primary |
| **Category** | Collaboration |
| **User Stories** | US-077, US-078 |

## Description

Single review at `/app/[orgId]/reviews/[id]` with pixel-anchored x/y overlay comments on a screenshot, compiled into a final verdict once review is complete.

## Key Components

- **Screenshot Overlay Canvas** — the target image with pinned comment markers (US-077)
- **Overlay Comment Pin** — a single x/y-anchored comment thread (US-077)
- **Verdict Compiler Panel** — aggregates open comments into a pass/fail/changes-requested verdict (US-078)
- **Comment Marker List** — sidebar listing all pins for quick navigation

## Interactions

- User clicks a point on the Screenshot Overlay Canvas → drops an Overlay Comment Pin and opens its comment field (US-077)
- User resolves outstanding pins and opens the Verdict Compiler Panel → selects a verdict and compiles the review (US-078)

## Navigation

- Accessible from: Reviews List (29)
- Links to: Ticket Detail (26) if the review is linked to a ticket
