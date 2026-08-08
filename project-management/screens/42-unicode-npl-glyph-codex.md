# Unicode/NPL Glyph Codex

| Field | Value |
|-------|-------|
| **ID** | `unicode-npl-glyph-codex` |
| **Type** | Primary |
| **Category** | Reference Data |
| **User Stories** | US-070 |

## Description

Searchable reference at `/app/[orgId]/unicode-codex` cataloging the Unicode and NPL-specific glyphs used across the platform's prompt syntax.

## Key Components

- **Glyph Search Bar** — keyword/character search across the codex (US-070)
- **Glyph Detail Card** — codepoint, name, NPL usage meaning, example (US-070)
- **Category Filter Sidebar** — narrows by glyph category/domain

## Interactions

- User types in the Glyph Search Bar → matching glyphs list live (US-070)
- User clicks a result → the Glyph Detail Card expands with full usage detail (US-070)

## Navigation

- Accessible from: Org Dashboard (17), NPL Conventions Browser (43)
- Links to: NPL Conventions Browser (43)
