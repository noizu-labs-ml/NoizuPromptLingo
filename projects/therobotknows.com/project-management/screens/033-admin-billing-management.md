# Admin Billing Management

| Field | Value |
|-------|-------|
| **ID** | admin-billing-management |
| **Type** | Primary |
| **Category** | Admin |
| **User Stories** | US-086 |

## DescriptionAdmin interface for subscription management, billing, and revenue tracking.

## Key Components

- **User Search** — Find user to view billing (US-086)
- **Billing Record Display** — Plan, cycle, renewal date, payment status, lifetime spend (US-086)
- **Failed Payment Flag** — Visual indicator on failed payments (US-086)
- **Manual Retry Button** — Trigger payment retry (US-086)
- **Grace Period Extension** — Extend payment window (US-086)
- **Plan Override Form** — Manual plan change with reason (US-086)
- **Revenue Summary Panel** — MRR, new subscriptions, churn, net revenue (US-086)
- **Refund Form** — Issue refund with confirmation (US-086)
- **Billing Audit Log** — History of billing operations (US-086)

## Interactions

- Failed payments visually flagged
- Manual retry attempts payment again
- Plan overrides noted with reason in audit log
- Refund initiated via payment processor
- User notified by email on refund
- Revenue metrics update in real-time

## Navigation

- Accessible from: Admin Dashboard (Billing link)
- Links to: User Billing Detail