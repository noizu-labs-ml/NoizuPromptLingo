# Knowledge Base Logo

## Concept: The Codex Graph

An open book (representing the library/canon) with three interconnected nodes forming a triangle above it (representing the knowledge graph). The book grounds the mark in the "scholar's library" metaphor; the constellation of nodes signals the living, AI-connected nature of the product.

## Files

| Variant | File | Use When |
|---------|------|----------|
| Full color mark | `knowledge-base-mark.svg` | Default, light/cream backgrounds |
| Combo mark | `knowledge-base-combo.svg` | Header lockup, marketing materials |
| Reversed | `knowledge-base-reversed.svg` | Dark backgrounds, dark mode |
| Mono black | `knowledge-base-mono.svg` | Print, single-color, fax |
| Favicon | `knowledge-base-favicon.svg` | Browser tabs, bookmarks, app icon |

## Colors

From the Vellum & Ink palette:

| Element | Light Mode | Dark/Reversed |
|---------|-----------|---------------|
| Book (left page) | `#1A1A1A` | `#FFFFFF` |
| Book (right page) | `#252118` | `#E8E2D9` |
| Spine + graph | `#8B4513` | `#C4956A` |
| Text "KNOWLEDGE" | `#1A1A1A` | — |
| Text "BASE" | `#6B6560` | — |

## Clear Space

Minimum clear space = 25% of mark height on all sides. The logomark's viewBox already includes ~15% built-in margin; maintain at least 10% additional when placing.

## Minimum Sizes

- **Combo mark:** 240px wide minimum
- **Logomark:** 40px wide minimum
- **Favicon:** 16px (purpose-built simplified variant)

## Don'ts

- Do not stretch or distort the aspect ratio
- Do not rotate the mark
- Do not change the graph/spine color independently of the palette
- Do not place on busy photographic backgrounds without a scrim
- Do not add shadows, outlines, or glow effects
- Do not rearrange the combo mark components

## Production Notes

The combo mark uses live `<text>` elements for easy iteration. Before shipping:

1. Install Lora font (or substitute Georgia/serif)
2. Convert text to paths: `inkscape input.svg --export-text-to-path --export-filename=output.svg`
3. Optimize: `npx svgo output.svg -o output.min.svg`
4. Verify rendering at 240px, 120px, and 80px widths
