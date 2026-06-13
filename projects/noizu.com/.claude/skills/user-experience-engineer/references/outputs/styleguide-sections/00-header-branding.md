# Header & Branding

> The identity layer that frames everything else in the style guide.

---

## Why This Section Exists

A style guide is not a token dump — it's a communication artifact. Opening with identity before design tokens establishes *who this system is for* and *what it should feel like* before diving into *how it's built*. The StyleCard and ProductBranding components together answer two questions every implementer asks first: "What is this?" and "What should it feel like?"

Without this framing, a style guide becomes a reference manual that nobody reads with intent.

## What to Include

### StyleCard (Hero Header)

The StyleCard is the cover page. It communicates:

- **Design system name** — via the `title` prop. This is the identity anchor. HTML is supported, so you can color-accent part of the name (e.g., `App<span style='color:var(--red)'>Name</span>`).
- **Subtitle** — a mono-uppercase line establishing the system's domain or tagline. Keep it to 3-5 words separated by middots or slashes.
- **Epigraph** — an italic design philosophy quote. This should be a real principle the system follows, not filler. It sets the intellectual tone. Good: "Perfection is achieved not when there is nothing more to add, but when there is nothing left to take away." Bad: "We strive to deliver best-in-class digital experiences."
- **Seal** — a large decorative unicode character rendered at low opacity. Purely atmospheric. Use a character that fits the brand's visual language (geometric shapes for modernist systems, ornamental glyphs for editorial ones) or omit it entirely.
- **Color bar** — a thin horizontal stripe of the palette's key colors. This gives an instant visceral read of the system's chromatic personality before any swatches appear.
- **Meta grid** — key/value design facts (typefaces, grid base unit, border radius, philosophy). These should be scannable single values, not sentences. "Space Grotesk" not "We use Space Grotesk as our primary typeface."

### ProductBranding (Brand Identity Card)

The ProductBranding card captures design intent in structured fields:

- **Name** — the product or brand name, displayed prominently.
- **Logo** — an SVG or placeholder. Pass a React node to the `logo` prop, or leave it to render the default dashed placeholder.
- **Style Intent** — what the design is trying to achieve (e.g., "Swiss modernist clarity with functional restraint").
- **Desired Perception** — how users should feel (e.g., "Precise, trustworthy, quietly confident").
- **Target Audience** — who the system serves (e.g., "Developers and technical writers").
- **Tone / Voice** — the communication register (e.g., "Direct, concise, no jargon unless precise").
- **Brand Keywords** — 5-7 attribute tags rendered as pills. These are the adjectives the brand owns.

## Best Practices

1. The epigraph should be a real design principle that actually governs decisions in this system — something you'd invoke during a design review.
2. Meta values should be scannable facts: "8px base", "2px radius", "Space Grotesk + IBM Plex Mono". No sentences.
3. The color bar should match the primary colors used in Section 02. If the palette changes, update both.
4. Keep brand keywords to 5-7. More than that dilutes meaning — if everything is a keyword, nothing is.
5. Style Intent and Desired Perception are different things. Intent is what the designer does; Perception is what the user feels. Don't collapse them.
6. The logo area should contain a real SVG. A placeholder signals the guide isn't finished.

## Template Usage

In `assets/styleguide-template.html`, the App component renders StyleCard and ProductBranding at the top, before any numbered sections.

### StyleCard props

| Prop | Type | Notes |
|------|------|-------|
| `title` | string (HTML) | Supports `<span>`, `<em>` for colored accents |
| `subtitle` | string | Mono uppercase, appears below title |
| `epigraph` | string | Italic quote, auto-wrapped in quotation marks |
| `seal` | string | Single unicode character, rendered large at 15% opacity |
| `colors` | string[] | CSS color values for the horizontal color bar |
| `meta` | {label, value}[] | Key/value pairs shown in a grid below the color bar |
| `heroStyle` | object | Optional inline style override for the hero area background |

### ProductBranding props

| Prop | Type | Notes |
|------|------|-------|
| `name` | string | Product/brand name |
| `logo` | node | React node (SVG, img, etc.) or omit for placeholder |
| `intent` | string | Style intent statement |
| `perception` | string | Desired user perception |
| `audience` | string | Target audience description |
| `tone` | string | Tone/voice description |
| `keywords` | string[] | Brand attribute tags, rendered as pills |
| `children` | node | Additional custom fields in the grid |

Replace all lorem ipsum placeholder text with real values. The template ships with generic Latin — every string prop needs real content.

## Anti-Patterns

- **Generic corporate epigraphs.** "We believe in innovation and excellence" says nothing. Use a specific design principle that actually constrains decisions.
- **Too many keywords.** More than 7 creates visual noise and semantic dilution. If you can't cut to 7, you haven't identified your brand.
- **Placeholder logos left in production guides.** The dashed-border placeholder is for the template only. Ship with a real mark.
- **Meta values as prose.** "Our primary typeface is Space Grotesk" belongs in documentation, not the meta grid. The grid is for "Space Grotesk".
- **Mismatched color bar.** If the color bar shows colors not defined in Section 02, the guide contradicts itself.

## Dependencies

- **References** Section 02 (Color Palette) — the color bar should use the same primary values.
- **References** Section 01 (Design Tokens) — meta values like typeface and grid unit should match token definitions.
- **Referenced by** all other sections — the brand identity here sets the tone that the rest of the guide implements.
