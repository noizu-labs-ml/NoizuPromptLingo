# Skeleton Loader

| Field | Value |
|-------|-------|
| **ID** | `skeleton-loader` |
| **Category** | Loading / Performance |
| **Used In** | All data-loading screens — S03 Universe Dashboard, S05 Canon List, S06 Entry Detail, S08 Knowledge Graph, S12 Generation History |

## Description

Animated placeholder that mimics the shape and dimensions of real content while data is being fetched. Uses a shimmer sweep animation on gray blocks scaled to match headings, body text, badges, cards, and images. Prevents layout shift and reduces perceived wait time. Each content type (entry card, table row, graph node, metric tile) has a named skeleton preset.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single-line text block; 100% width of parent; used for list row placeholders |
| **Compact** | Multi-line block with icon placeholder; used for entry cards and sidebar rows |
| **Expanded** | Full card or panel layout with header, body, and footer placeholders |

## Props / Configuration

- `preset` — `text-line | text-block | entry-card | table-row | metric-tile | graph-node | avatar | image`; selects the appropriate shape template
- `lines` — Number; for `text-block` preset, how many lines to render; defaults to 3
- `width` — String or number; overrides default width; useful for variable-length inline skeletons
- `animate` — Boolean; enables shimmer; defaults to true; disabled when `prefers-reduced-motion` is active
- `count` — Number; renders N repetitions of the skeleton; used to fill a list while loading
- `className` — String; additional CSS classes for layout positioning

## Interactions

- No user interactions; purely visual
- Shimmer animation is a CSS `@keyframes` sweep on a gradient background; GPU-composited
- Hidden from screen readers via `aria-hidden="true"`; a separate `aria-live` region announces loading state
- Automatically removed from DOM when parent component receives data and re-renders
