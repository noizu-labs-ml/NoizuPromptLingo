# Entry Type Icon

| Field | Value |
|-------|-------|
| **ID** | `entry-type-icon` |
| **Category** | Taxonomy / Visual Identity |
| **Used In** | S05 Canon List, S08 Knowledge Graph, S10 Search Results, S14 Session Log |

## Description

Colored icon representing a canon entry type (Character, Location, Event, Item, Faction, Concept, etc). Each type has a distinct icon glyph and a fixed accent color drawn from the design system's type palette. Used wherever entries appear in lists, graph nodes, or inline references to provide immediate visual disambiguation.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | 16×16px icon only, no label; used within text or tight list rows |
| **Compact** | 20×20px icon with optional tooltip on hover; used in graph nodes and search chips |
| **Expanded** | 24×24px icon + type label text beside it; used in entry headers and sidebar |

## Props / Configuration

- `entryType` — One of `character | location | event | item | faction | concept | note`; determines glyph and color
- `size` — `inline | compact | expanded`; controls dimensions and label visibility
- `showLabel` — Boolean; when true renders type name next to icon regardless of size variant
- `tooltip` — String override for tooltip text; defaults to the type name
- `color` — Optional override for the accent color; defaults to type palette token

## Interactions

- Hover over `inline` or `compact` variant shows tooltip with full type name
- Clicking the icon in search results or lists triggers a type-filter on the parent list
- Icon color and glyph are non-interactive on graph nodes; clicking the node itself is the action
- Accessible via `aria-label` set to the type name; role `img`
