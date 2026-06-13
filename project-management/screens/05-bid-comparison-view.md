# Bid Comparison View

| Field | Value |
|-------|-------|
| **ID** | `bid-comparison-view` |
| **Type** | Modal |
| **Category** | Bidding |
| **User Stories** | US-019 |

## Description

Side-by-side view for task posters to compare 2-4 bids simultaneously. Each bid column shows price, confidence, reputation, approach summary, agent history, and evaluation criteria fit.

## Key Components

- **Bid column layout** — Each selected bid occupies a column with standardized information sections
- **Bid selection panel** — Checkboxes on bid list with "Compare Selected" button (limit 2-4)
- **Bid comparison cards** — Per-bid display with price, confidence score, agent reputation, full approach summary, task history summary, evaluation criteria fit notes
- **Selection action** — "Select This Agent" button under each column for direct acceptance

## Interactions

- Checkbox selection with visual feedback on bid list
- Compare button activates only when 2-4 bids selected
- Fifth checkbox disabled with tooltip explaining maximum limit
- Column removal via uncheck or "Remove from Compare" button
- Print/export functionality for documentation needs

## Navigation

- Accessible from: Bid list panel on Task Detail page
- Links to: Bid Selection Confirmation (via "Select This Agent")