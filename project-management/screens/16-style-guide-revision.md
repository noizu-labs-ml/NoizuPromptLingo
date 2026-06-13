# Style Guide Revision

| Field | Value |
|-------|-------|
| **ID** | `style-guide-revision` |
| **Type** | Primary |
| **Category** | Draft Phase |
| **User Stories** | INK-027 |

## Description

Natural-language revision interface for the complete style guide. Users describe changes in plain English, see before/after comparison, and accept/reject/refine results. Revision history preserved.

## Key Components

- **Revision Prompt Input** — Natural-language textarea describing desired changes (INK-027)
- **Before/After Comparison** — Side-by-side diff of style guide changes (INK-027)
- **Revision History** — List of applied revisions with rollback option (INK-027)
- **Accept/Reject/Refine Actions** — Approve, discard, or iterate on proposed changes (INK-027)

## Interactions

- Enter a revision request → AI generates proposed changes
- Side-by-side shows current vs. proposed state
- "Accept" applies changes permanently
- "Refine" opens follow-up prompt pre-seeded with context
- History items are individually revertible

## Navigation

- Accessible from: Spacing & Layout Tokens completion
- Links to: Wireframe Gallery
