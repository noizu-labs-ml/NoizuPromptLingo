# 03 — Typography

> The type hierarchy rendered live, showing every text level with its metadata and intended use.

---

## Why This Section Exists

Typography is the primary communication channel of any interface. Users read before they see — text carries meaning, hierarchy carries structure, and type choices carry tone. Section 01 defines font family tokens. This section shows the complete type scale as rendered specimens: what each level looks like at actual size, what its specs are, and when to use it. Without a documented type hierarchy, implementers invent heading sizes ad hoc and the visual rhythm breaks.

## What to Include

### The Type Scale

A type scale is a defined set of text levels, each with consistent properties. Typical levels, from largest to smallest:

| Level | Typical Use | Example Size |
|-------|-------------|-------------|
| **Display** | Hero headlines, landing page statements | 48-64px |
| **H1** | Page/section titles | 28-36px |
| **H2** | Subsection headings | 20-24px |
| **H3** | Card titles, tertiary headings | 16-18px |
| **Body** | Paragraph text, long-form content | 15-16px |
| **Code** | Code blocks, monospace content | 13-14px |
| **Label** | UI labels, form labels, navigation | 11-13px |
| **Data** | Metadata, timestamps, captions | 10-12px |

Not every system needs all these levels. A documentation site might skip Display. A dashboard might add a Data level. Define what you actually use.

### Per-Level Specification

Each level needs:
- **Font family** — which typeface (sans or mono)
- **Weight** — numeric weight (400, 500, 600, 700)
- **Size** — in pixels or rem
- **Line height** — as a unitless multiplier (1.2, 1.5, 1.8)
- **Usage context** — where this level appears in the UI (optional but valuable)

### Sample Text

Sample text should demonstrate the actual use case, not placeholder:
- Display: "The system works" or an actual product tagline
- H1: "Design Tokens" or a real section name
- Body: A real paragraph about the product, not lorem ipsum
- Code: Actual code — `const theme = 'swiss';`
- Label: "Email Address" or "Last Modified"
- Data: "2024-01-15 14:32 UTC" or "v2.1.0"

Realistic samples let reviewers evaluate whether the type level *actually works* for its intended context.

## Best Practices

1. **Two typefaces maximum.** One sans-serif and one monospace is the sweet spot. Adding a serif "for variety" usually creates noise without solving a problem.
2. **Constrain weights.** 400 (regular), 500 (medium), 600 (semi-bold), and 700 (bold) cover virtually every use case. If you're reaching for 300 or 800, reconsider the hierarchy.
3. **Test at actual sizes.** A specimen rendered in a style guide is not the same as text in a real layout. Verify that the scale works in context — especially body text line lengths and heading sizes on mobile.
4. **Line height scales inversely with size.** Large display text needs tight line height (0.9-1.1). Body text needs generous line height (1.5-1.7). This is almost always the right pattern.
5. **Code specimens should use real code.** `console.log("hello world")` is fine. Lorem ipsum in a monospace font teaches nothing.
6. **Document usage, not just specs.** "H2 — subsection headings" tells an implementer when to reach for this level. Raw specs alone leave them guessing.

## Template Usage

In the styleguide-engine, Section 03 renders TypeSpecimen components for each level in the type scale. **Engine facet:** `style-guide.typography.yaml`.

### TypeSpecimen props

| Prop | Type | Notes |
|------|------|-------|
| `name` | string | Level label (e.g., "Display", "Body", "Code") |
| `font` | string | Font family name — renders the sample in this font |
| `weight` | number | Font weight applied to the sample |
| `size` | string | Font size with unit (e.g., "48px", "1rem") |
| `lineHeight` | number | Line height multiplier (e.g., 1.2, 1.5) |
| `sample` | string | Text rendered in the specimen style |
| `usage` | string | Optional usage note displayed in the metadata column |

### Layout

TypeSpecimen renders as a two-column row:
- **Left column (200px):** metadata block showing the level name (bold, uppercase), font/weight, size/lineHeight, and the optional `usage` note in italic
- **Right column:** the sample text rendered live at the specified font, weight, size, and line height

Stack multiple TypeSpecimen components vertically. Each is separated by a thin bottom border. The progression from Display down to Data should create a clear visual hierarchy on the page itself.

### Subsections

You may want a subsection title (using `sg-subsection-title` class or a simple heading) before the specimens if you separate them into groups (e.g., "Headings" and "Body/UI Text").

Use SectionDesc to add an introductory paragraph about the type philosophy before the specimens begin.

## Anti-Patterns

- **More than 3 typefaces.** Every additional typeface increases cognitive load and download weight. Two is ideal. Three is the ceiling.
- **Type scale that doesn't match the UI.** If the style guide shows an H3 at 18px but the actual app renders it at 16px, the guide is a lie. Keep them in sync.
- **Lorem ipsum specimens.** "Lorem ipsum dolor sit amet" in a Display specimen tells you nothing about whether that size and weight work for actual headlines. Use real content.
- **Missing usage context.** Specs without usage create ambiguity. If someone sees a 13px semi-bold specimen, they need to know it's for UI labels, not body text.
- **Inconsistent weight usage.** If H1 is 700, H2 is 600, and H3 is 700 again, the weight pattern is broken. Weight should reinforce hierarchy, not contradict it.
- **No monospace specimen.** If the system uses code blocks or data displays, the monospace typeface needs its own specimen row. Don't leave implementers to guess the mono specs.

## Dependencies

- **References** Section 01 (Design Tokens) — font family tokens (`--font-sans`, `--font-mono`) defined there are rendered here.
- **Referenced by** all content sections — every text element in the UI should map to a level defined in this scale.
- **Related to** Section 04 (Spacing) — line height and type size interact with vertical spacing. Changes here may affect spacing rhythm.
