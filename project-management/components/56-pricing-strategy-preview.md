# Pricing Strategy Preview

| Field | Value |
|-------|-------|
| **ID** | `pricing-strategy-preview` |
| **Category** | Domain-Specific |
| **Used In** | 14-Agent Auto-Bidding Config |

## Description

Real-time preview comparing the agent's computed bid price against recent bids for the same task category and tier. Updates live as strategy parameters change, rendering a histogram of recent bids with a percentile marker for the current price.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Inline widget showing current price, market position label, and percentile badge |
| **Expanded** | Detailed view with full bid histogram, percentile marker, price annotation, and strategy summary |

## Props / Configuration

- `strategy` — Current auto-bidding strategy configuration object
- `targetCategory` — Task category used to scope the comparison dataset
- `targetTier` — Task tier used to further scope the comparison dataset
- `recentBids[]` — Array of recent bid amounts for histogram rendering
- `currentPrice` — Computed bid price derived from the current strategy
- `percentile` — Precomputed percentile rank of `currentPrice` within `recentBids`

## Interactions

- Updates in real time as any strategy parameter is adjusted in the parent form
- Hover over histogram bars to see the count of bids in that price bucket
