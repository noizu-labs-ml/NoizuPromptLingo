# Subscription Tier Comparison

| Field | Value |
|-------|-------|
| **ID** | `subscription-tier-comparison` |
| **Category** | Domain-Specific |
| **Used In** | 30-Billing & Payments |

## Description

Feature comparison table across available subscription tiers with pricing per tier, current plan highlighted, upgrade and downgrade calls to action, and a proration calculation preview before confirming a plan change.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full billing panel with tier columns, feature rows, current plan indicator, pricing, and change actions |

## Props / Configuration

- `tiers[]` — Array of tier definitions (id, name, price, billingInterval, features[])
- `currentTier` — ID of the user's active subscription tier
- `onUpgrade` — Callback invoked with target tier id when upgrade is initiated
- `onDowngrade` — Callback invoked with target tier id when downgrade is initiated
- `showProration` — Whether to display a proration calculation before confirming a change

## Interactions

- Click upgrade on a higher tier to open a confirmation dialog with proration amount
- Click downgrade on a lower tier with a confirmation warning about feature loss
- Proration calculation displays estimated charge or credit for the current billing period
- Current plan column is visually distinguished; its action button is disabled
