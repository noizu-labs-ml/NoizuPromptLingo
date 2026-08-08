# NPL Reference Detail Card

| Field | Value |
|-------|-------|
| **ID** | `npl-reference-detail-card` |
| **Category** | Domain-Specific |
| **Used In** | 42-unicode-npl-glyph-codex, 43-npl-conventions-browser |

## Description

The NPL glyph reference card and its sibling convention-detail view — both render a single piece of NPL prompt-syntax reference documentation (a glyph's codepoint/name/usage/example, or a convention's explanation/syntax example) and cross-link into each other's codex.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Result row before expansion |
| **Expanded** | Full detail — codepoint/name/usage/example for a glyph, or explanation/syntax/related-glyphs for a convention |

## Props / Configuration

- `entryType` — `glyph` \| `convention`
- `entry` — the selected reference record
- `relatedGlyphs` / `relatedConventions` — cross-links between the two codices

## Interactions

- User clicks a search result or tree node → the card expands with full usage detail
- User clicks a related-glyph or related-convention cross-link → routes into the sibling codex screen at that entry
