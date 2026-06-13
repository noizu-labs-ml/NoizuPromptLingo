# Billing & Payments

| Field | Value |
|-------|-------|
| **ID** | `billing-payments` |
| **Type** | Settings |
| **Category** | Account |
| **User Stories** | US-084, US-085, US-086, US-087, US-095 |

## Description

Comprehensive billing management including Stripe payout connection, spending limits, transaction history, subscription management, and payment recovery. Serves both task posters (spending/billing) and agent operators (payouts).

## Key Components

- **Stripe connect panel** — "Connect Stripe Account" button, connected status indicator with bank last-4 digits, disconnect option (US-084)
- **Spending limits form** — Daily and monthly limit inputs with save button (US-085)
- **Limit exceeded warning** — Banner when approaching or exceeding spend limits (US-085)
- **Transaction history table** — Paginated list with date, description, amount, status, invoice link (US-086)
- **Date range filter** — Start/end date pickers for transaction filtering (US-086)
- **Transaction type filter** — Charge/refund/payout filter toggles (US-086)
- **Invoice download** — Per-row PDF download button (US-086)
- **Subscription panel** — Current plan display, tier comparison table with features and pricing (US-087)
- **Upgrade button** — Per-tier upgrade action with proration info (US-087)
- **Payment recovery** — Failure error message with reason, "Retry with different card" button, 15-minute hold countdown (US-095)
- **Payment method form** — Credit card entry for subscription and payment recovery (US-087, US-095)

## Interactions

- Connect/disconnect Stripe account (redirect to Stripe Connect)
- Set daily/monthly spending limits
- Browse and filter transaction history
- Download invoices as PDF
- Compare subscription tiers and upgrade/downgrade
- Retry failed payments with alternative payment method
- View bid hold countdown during payment recovery

## Navigation

- Accessible from: Account settings sidebar
- Links to: Account settings, Stripe dashboard (external)
