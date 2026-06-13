# Billing Summary Card

| Field | Value |
|-------|-------|
| **ID** | `billing-summary-card` |
| **Category** | Admin |
| **Used In** | S-24 Admin Billing Management |

## Description

Card displaying a user's or account's billing overview: plan name, billing cycle, next renewal date, payment status, and lifetime spend. Surfaces quick-action links for plan changes, payment method updates, and invoice history.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Plan name, status badge, renewal date, and a single "Manage" link — used in admin user list row expansion |
| **Expanded** | Full card with all billing fields, usage bar, lifetime spend, and action buttons — used on the dedicated billing management screen |

## Props / Configuration

- `accountId` — Account or user ID the billing record belongs to
- `planName` — Display name of the current subscription plan (e.g., "Lore Keeper Pro")
- `billingCycle` — `"monthly"` | `"annual"`
- `renewalDate` — ISO date string of next renewal or expiry
- `paymentStatus` — `"active"` | `"past_due"` | `"cancelled"` | `"trialing"` | `"paused"`
- `lifetimeSpend` — Total spend in cents; rendered as formatted currency
- `currentPeriodUsage` — Object with `{ used, limit, unit }` for the primary metered resource (e.g., generation tokens)
- `variant` — `"compact"` | `"expanded"` (default: `"expanded"`)
- `onChangePlan` — Callback for Change Plan action
- `onUpdatePayment` — Callback for Update Payment Method action
- `onViewInvoices` — Callback for View Invoices action

## Interactions

- Payment status badge uses semantic colors: green (active/trialing), amber (past_due), red (cancelled), grey (paused)
- Past-due status adds a prominent warning banner above the card with a "Fix Payment" CTA
- Usage bar shows current period consumption against the plan limit with color coding (green < 75%, amber 75–95%, red > 95%)
- Renewal date shows relative time ("in 14 days") with absolute date in tooltip; overdue shows "Expired X days ago" in red
- Change Plan opens the plan selection modal with upgrade/downgrade options
- Admin view includes a "Override Plan" field for manually assigning plans outside the normal billing flow
- Lifetime spend is admin-only; not shown in the user-facing account settings version of this card
