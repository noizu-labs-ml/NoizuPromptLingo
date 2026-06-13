# Billing Settings

| Field | Value |
|-------|-------|
| **ID** | `billing-settings` |
| **Type** | Settings |
| **Category** | Platform |
| **User Stories** | INK-074, INK-075, INK-076, INK-077 |

## Description

Subscription management screen showing current plan, tier comparison, usage tracking, and billing history. Upgrade flow uses in-app modal (not redirect) with Stripe integration.

## Key Components

- **Pricing Comparison Table** — 4-tier display (Free/Pro/$19/Builder/$49/Launch/$99) with feature rows and "Current Plan" badge (INK-074)
- **Upgrade Modal** — Contextual in-app modal with Stripe payment form and immediate unlock (INK-075)
- **Compute Usage Meter** — Gauge showing usage vs. allowance with per-project breakdown (INK-076)
- **Overage Alert Banner** — In-app warning when approaching/exceeding limits (INK-076)
- **Billing History Table** — Date/amount/description/status rows with PDF invoice download (INK-077)
- **Billing Info Editor** — Email + company name for invoice customization (INK-077)

## Interactions

- Annual/Monthly toggle on pricing table
- "Upgrade" opens contextual modal (not full redirect)
- Stripe form handles payment; immediate feature unlock on success
- Usage meter updates in real-time
- Overage alerts appear as persistent banner
- Download individual invoices as PDF

## Navigation

- Accessible from: Settings nav, Dashboard upgrade prompts, locked feature tooltips
- Links to: Stripe payment (embedded), Invoice downloads
