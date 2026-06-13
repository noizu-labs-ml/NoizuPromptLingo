# Section 09 — Cards

> Content containers that establish the compound component pattern.

---

## Why This Section Exists

Cards are the first "compound" component in the style guide. Unlike buttons or badges, a card *contains* other elements — titles, body text, tags, metadata, IDs. This makes cards the place where the container pattern is established: how do grouped elements sit inside a box? What padding, spacing, and hierarchy rules apply when multiple primitives share a surface?

Every composite component that follows (project components, screen layouts) inherits the containment logic defined here. Get cards right and the rest composes naturally.

## What to Include

### Variant System

Define 3-4 card variants maximum:

- **Standard** — border only, neutral background. The default. Used for most content.
- **Accent** — colored top border (2-4px). Draws attention to featured or promoted items. Border color should carry semantic meaning (e.g., primary accent for featured, warning color for flagged).
- **Filled / Inverted** — dark background, light text. High visual weight. Reserved for CTAs, key metrics, or emphasis blocks.
- **Colored border** — full border in a semantic color. For status-grouped content (e.g., all "in progress" items share a border color).

### Card Anatomy

Each card can contain:

- **ID** — optional, rendered in monospace, small size, gray. Appears top-right or top-left. Used for reference codes, ticket numbers.
- **Title** — bold, using the heading scale from Section 03. Primary scan target.
- **Body text** — regular weight, body size. 2-3 lines max before the card becomes a list item.
- **Tags / Badges** — categorization and status indicators at the bottom of the card.

### Tag Format

Tags accept two formats:

- **Plain string** — rendered with default tag styling from Section 08.
- **Styled object** — `{label, bg, color}` for custom-colored tags. Used when tags represent categories with brand-specific colors.

## Best Practices

- Use 3-4 variants maximum. More than that and the visual hierarchy collapses.
- Accent border color on top should match semantic meaning — don't use random colors.
- Filled/inverted cards are loud. Use them for CTAs or single-emphasis blocks, not as the default.
- Maintain consistent internal padding across all variants. A card is a card regardless of its surface treatment.
- Show multiple variants side by side in the style guide so the visual differences are immediately clear.
- Tags should not dominate the card. If a card has more tags than body text, reconsider the information architecture.

## Template Usage

### Components

- `Card` — props: `variant`, `title`, `body`, `id`, `tags`, `children`
- `CardGrid` — wrapper that arranges cards in a responsive grid

### CSS Classes

Define `.card-standard`, `.card-accent`, `.card-filled`, `.card-bordered` variant classes. Internal spacing uses the spacing scale from Section 04.

### Tag Handling

The `tags` prop accepts an array of strings or `{label, bg, color}` objects. Mixed arrays are valid — plain strings get default styling, objects get custom colors.

### Display

Show all variants in a single `CardGrid` so differences are scannable at a glance. Include at least one card with an ID, one with tags, and one with both.

## Anti-Patterns

- **Overstuffed cards** — if a card needs 6+ fields, it's a list item or a detail panel, not a card. Cards are for scannable summaries.
- **Inconsistent padding between variants** — the accent card has 16px padding but the filled card has 24px. Internal spacing must be uniform.
- **Filled cards everywhere** — using the highest-emphasis variant as the default defeats its purpose. Filled cards should be rare.
- **Tags without meaning** — decorative tags that don't filter, sort, or categorize anything. Every tag should serve navigation or comprehension.
- **Cards without visual grouping** — loose cards floating on a page. Cards belong in grids or lists with consistent gutters.

## Dependencies

| Section | What It Provides |
|---|---|
| 02 — Color Tokens | Card background, border, and text colors |
| 03 — Typography | Title and body text scales |
| 04 — Spacing | Internal padding and grid gutters |
| 08 — Status & Metadata | Tag/badge styling conventions |
