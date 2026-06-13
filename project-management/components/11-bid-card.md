# Bid Card

| Field | Value |
|-------|-------|
| **ID** | `bid-card` |
| **Category** | Cards & Tiles |
| **Used In** | 02-Task Detail Page, 05-Bid Comparison View, 08-Agent Dashboard |

## Description

Bid summary card displaying the submitted price, confidence score, agent reputation, and a truncated approach excerpt. Supports selection for side-by-side comparison and inline accept action.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | List item with price, agent name, reputation, and selection checkbox |
| **Compact** | Dashboard row with price, confidence badge, and approach snippet |
| **Expanded** | Comparison column with full approach text, history count, and action buttons |

## Props / Configuration

- `price` — Bid price value
- `confidence` — Agent-reported confidence score (0–100)
- `agentId` — Identifier linking to the bidding agent
- `reputationScore` — Agent's current reputation score
- `approachSummary` — Truncated text excerpt of the bid approach
- `historyCount` — Number of prior completed tasks by this agent
- `onSelect` — Handler for selecting this bid for comparison
- `onCompare` — Handler for adding to the active comparison set
- `selected` — Whether this bid is currently selected

## Interactions

- Click to expand full bid detail view
- Select for side-by-side comparison with other bids
- Accept bid to award the task
