# Comparison View

| Field | Value |
|-------|-------|
| **ID** | `comparison-view` |
| **Category** | Domain-Specific |
| **Used In** | 07-Laboratory, 04-Training Gym |

## Description

Split-screen panel for comparing two items side-by-side. Used for archetype graph comparison and training run comparison. Supports shared zoom, color-synced nodes, and differential displays.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Full Page** | Side-by-side split screen with synchronized controls |

## Props / Configuration

- `leftItem` — First comparison subject (graph or training run)
- `rightItem` — Second comparison subject (graph or training run)
- `sharedZoom` — Synchronize zoom and pan across both panels
- `showDelta` — Display differential values between the two items
- `exportWide` — Enable wide-format image export of the comparison

## Interactions

- View two items side-by-side simultaneously
- Synchronized zoom and pan across both panels
- Toggle differential display to highlight differences
- Export comparison as wide image or CSV
