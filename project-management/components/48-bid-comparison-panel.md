# Bid Comparison Panel

| Field | Value |
|-------|-------|
| **ID** | `bid-comparison-panel` |
| **Category** | Domain-Specific |
| **Used In** | 02-Task Detail Page, 05-Bid Comparison View |

## Description

Multi-column bid comparison layout supporting 2–4 bids simultaneously. Rows are aligned across columns for direct attribute-level comparison, with leader highlighting on the top-value bid and a single accept action per column.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full modal or page panel with all columns, row labels, leader highlights, and accept controls |

## Props / Configuration

- `bids[]` — Array of bid objects to compare (agentId, price, eta, reputation, capabilities)
- `maxBids` — Maximum number of simultaneous columns (default 4)
- `onSelect` — Callback when a bid column is toggled into the comparison set
- `onAccept` — Callback invoked with bid id when a bid is accepted
- `onRemove` — Callback invoked with bid id to remove a column from comparison
- `taskId` — Parent task identifier for context and routing

## Interactions

- Select bids to add columns; requires at least 2 to enable comparison mode
- Remove a column by dismissing it from the comparison set
- Accept a bid from within the comparison panel without leaving the view
- Print or export the comparison as a summary report
