---
id: US-086
title: "Admin Billing Management"
slug: "admin-billing-management"
personas: [P-006]
epic: "Admin & Moderation"
priority: "must-have"
complexity: "M"
tags: [admin, billing, subscriptions, payments, revenue]
---

# US-086: Admin Billing Management

## User Story

**As a** platform administrator (P-006),
**I want to** view subscription statuses, manually override plans, issue refunds, and see revenue metrics,
**So that** I can handle billing exceptions, support escalations, and monitor platform revenue health.

## Acceptance Criteria

- [ ] Given I am on /admin/billing, when I search for a user, then I see their current plan, billing cycle, next renewal date, payment method status, and lifetime spend.
- [ ] Given a user's payment has failed, when I view their billing record, then the account is visually flagged and I can trigger a manual retry or extend their grace period.
- [ ] Given I apply a manual plan override (e.g., grant pro access for 30 days), when I save, then the override is applied immediately and noted with a reason in the billing audit log.
- [ ] Given I view the revenue summary panel, when I look at the current month, then I see MRR, new subscriptions, churned subscriptions, and net revenue after refunds.
- [ ] Given I issue a refund for a transaction, when I confirm, then the refund is initiated via the payment processor, a record is created, and the user is notified by email.

## Notes

Depends on US-083 (admin dashboard). Billing operations must integrate with the payment processor (e.g., Stripe) via server-side API only — no client-side secret keys. Related: US-079 (generation budget).
