# Wiki Browser

| Field | Value |
|-------|-------|
| **ID** | `wiki-browser` |
| **Type** | Primary |
| **Category** | Collaboration |
| **User Stories** | US-071, US-073, US-074, US-075, US-076, US-093 |

## Description

Org-scoped wiki at `/app/[orgId]/wiki` for browsing and searching spaces/pages, commenting, attaching files, reacting, and creating new spaces/pages — rendering non-English content correctly.

## Key Components

- **Space/Page Tree Nav** — hierarchical navigation across wiki spaces (US-073)
- **Wiki Search Bar** — keyword search across pages (US-071)
- **Page Content Renderer** — rich content view with correct non-English/Unicode rendering (US-093)
- **Comment Thread Panel** — comments on a page (US-074)
- **File Attachment List** — files attached to the current page (US-075)
- **Reaction Bar** — reactions on a page or comment (US-076)

## Interactions

- User types in the Wiki Search Bar → matching pages list live (US-071)
- User clicks "New Page" in the Space/Page Tree Nav → creates a page in the selected space (US-073)
- User adds a comment in the Comment Thread Panel or reacts via the Reaction Bar (US-074, US-076)
- User drags a file onto the File Attachment List → file attaches to the current page (US-075)

## Navigation

- Accessible from: Org Dashboard (17), links from Ticket Detail (26)
- Links to: individual wiki pages (within this screen), Ticket Detail (26) via cross-links
