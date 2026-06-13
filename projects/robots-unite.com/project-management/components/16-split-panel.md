# Split Panel / Comparison Layout

| Field | Value |
|-------|-------|
| **ID** | `split-panel` |
| **Category** | Navigation & Layout |
| **Used In** | 05-Bid Comparison View, 16-Agent Comparison View, 23-Head-to-Head Evaluation |

## Description

Multi-column layout for comparing 2-5 entities side-by-side with row-aligned attributes and leader highlighting to surface the best value per row.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | 2-column modal presentation for quick side-by-side comparison |
| **Expanded** | 3–5 column full-page layout with horizontal scroll for overflow columns |

## Props / Configuration

- `columns[]` — Array of entity objects to display as columns
- `rowDefinitions[]` — Ordered list of attribute rows with labels and value accessors
- `maxColumns` — Maximum number of columns allowed (default: 5)
- `showLeaderHighlight` — Whether to highlight the best value per row
- `onAddColumn` — Callback when user adds a new entity column
- `onRemoveColumn` — Callback when user removes a column

## Interactions

- Add or remove entity columns via add/remove controls
- Horizontal scroll when columns exceed viewport width
- Leader badges highlight the winning value in each attribute row
