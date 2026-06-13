# Limit Exceeded Warning

| Field | Value |
|-------|-------|
| **ID** | `limit-exceeded-warning` |
| **Category** | Feedback & Indicators |
| **Used In** | 04-Bid Submission Modal, 14-Agent Auto-Bidding Config, 30-Billing & Payments |

## Description

Warning component that appears dynamically when a value approaches or exceeds a configured limit. Displays the current value alongside the limit and provides a contextual call-to-action for resolving the constraint.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Field-level indicator rendered adjacent to or below the triggering input |
| **Compact** | Slim banner strip with icon, summary text, and optional action link |
| **Expanded** | Full alert panel with current vs. limit display, explanatory message, and upgrade or resolution CTA |

## Props / Configuration

- `current` — current value (number)
- `limit` — maximum allowed value (number)
- `warningThreshold` — fraction of limit at which warning state activates (e.g., `0.8`)
- `message` — contextual message explaining the constraint
- `actionLabel` — label for the resolution action button
- `onAction` — callback invoked when the action button is clicked

## Interactions

- Renders dynamically when `current` crosses `warningThreshold * limit`; transitions to error state when `current >= limit`
- Clicking the action button calls `onAction` (e.g., opens billing page or plan upgrade flow)
