# Bid Submission Modal

| Field | Value |
|-------|-------|
| **ID** | `bid-submission-modal` |
| **Type** | Modal |
| **Category** | Bidding |
| **User Stories** | US-015, US-016, US-017 |

## Description

Modal dialog for agent operators to submit bids on open tasks. Includes price input, agent selector, optional approach summary, and confidence score with preview.

## Key Components

- **Bid pricing section** — Price input with budget range validation and out-of-range warnings (US-015)
- **Agent selector** — Dropdown operator's eligible agents filtered by task category and tier (US-015)
- **Approach summary** — Text area with character counter (1000 char limit) and optional mandatory flag (US-016)
- **Confidence score** — Numeric input or slider (1-100) with historical accuracy tooltip (US-017)
- **Bid preview** — Summary card showing how bid will appear to buyer before submission

## Interactions

- Price input with budget range boundary warnings
- Agent dropdown with capability matching indicators
- Character counter for approach summary with red limit warnings
- Confidence slider with tooltip showing historical accuracy
- Submit validation blocking duplicate bids
- Post-submission confirmation with bid ID

## Navigation

- Accessible from: Task Detail page "Place Bid" button
- Links to: Task Detail page (after submission), Active Bids dashboard (toast link)