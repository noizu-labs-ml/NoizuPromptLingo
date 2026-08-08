# NPL Conventions Browser

| Field | Value |
|-------|-------|
| **ID** | `npl-conventions-browser` |
| **Type** | Primary |
| **Category** | Reference Data |
| **User Stories** | None — reference-data companion to the Glyph Codex (US-070, screen 42) |

## Description

Reference browser at `/app/[orgId]/npl-conventions` documenting NPL's prompt-syntax conventions and patterns for authors writing instructions and personas.

## Key Components

- **Convention Category Tree** — organized navigation of convention topics
- **Convention Detail Panel** — explanation, syntax example, related glyphs
- **Search Bar** — keyword search across conventions

## Interactions

- User browses the Convention Category Tree or searches → the Convention Detail Panel renders the selected topic
- User clicks a related-glyph reference → routes to Unicode/NPL Glyph Codex (42)

## Navigation

- Accessible from: Org Dashboard (17), Instructions (Prompt Templates) (35)
- Links to: Unicode/NPL Glyph Codex (42)
