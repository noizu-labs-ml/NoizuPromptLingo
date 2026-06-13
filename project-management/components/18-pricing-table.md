# Pricing Table

| Field | Value |
|-------|-------|
| **ID** | `pricing-table` |
| **Category** | Data Display |
| **Used In** | 01-Landing Page, 29-Billing Settings |

## Description

4-tier comparison table (Free/$0, Pro/$19, Builder/$49, Launch/$99) with feature rows, annual/monthly toggle, recommended tier highlight, and per-tier CTA buttons.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Swipeable cards on mobile with sticky tier selector |
| **Full Page** | Side-by-side 4-column table with feature comparison rows |

## Props / Configuration

- `tiers` — Array of {name, price, features, recommended, cta}
- `billingCycle` — monthly | annual
- `currentTier` — User's current plan (for "Current Plan" badge)
- `showAnnualToggle` — Boolean

## Interactions

- Toggle switches monthly/annual pricing (with savings callout)
- Recommended tier visually highlighted
- CTA per tier triggers upgrade flow or signup
- Mobile: swipe between tiers, sticky selector at top
