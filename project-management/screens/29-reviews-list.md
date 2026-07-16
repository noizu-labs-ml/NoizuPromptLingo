# Reviews List

| Field | Value |
|-------|-------|
| **ID** | `reviews-list` |
| **Type** | Primary |
| **Category** | Collaboration |
| **User Stories** | US-077 |

## Description

Org-scoped listing of code reviews at `/app/[orgId]/reviews`, the entry point for starting a new overlay-annotated review before moving into its detail view.

## Key Components

- **Review Table** — status (open/compiled), reviewer, target screenshot thumbnail
- **Create Review Button** — starts a new review by uploading/selecting a screenshot (US-077)
- **Review Status Filter** — open/compiled/all filter chips

## Interactions

- User clicks Create Review Button → uploads a screenshot and is routed into Review Detail (30) to place overlay comments (US-077)
- User clicks a Review Table row → opens that review's Review Detail (30)

## Navigation

- Accessible from: Org Dashboard (17), Session Detail (21)
- Links to: Review Detail (30)
