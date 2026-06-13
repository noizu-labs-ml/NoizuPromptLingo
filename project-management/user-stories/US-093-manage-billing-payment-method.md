---
id: US-093
title: "Manage Billing and Payment Method"
slug: "manage-billing-payment-method"
personas: [P-001, P-002, P-006]
epic: "Monetization & Subscriptions"
priority: "must-have"
complexity: "M"
tags: [billing, payment, account, stripe, subscription]
---

# US-093: Manage Billing and Payment Method

## User Story

**As a** Web Nostalgia Explorer (P-001),
**I want to** view and update my billing information and payment method from my account settings,
**So that** I can keep my subscription active without interruption when my card changes.

## Acceptance Criteria

- [ ] Given I am a paying subscriber, when I navigate to Account > Billing, then I see my current plan, next billing date, billing amount, and last 4 digits of my payment method
- [ ] Given I click "Update Payment Method," when I am redirected to the Stripe Customer Portal, then I can update my card details without re-entering my gotta.cc credentials
- [ ] Given I update my payment method successfully, when I return to the billing page, then the updated card's last 4 digits are reflected within 60 seconds
- [ ] Given I want to download an invoice, when I click on a past invoice in my billing history, then a PDF invoice opens or downloads
- [ ] Given I am a free-tier user, when I navigate to the billing page, then I see my current plan as "Free" with a clear upgrade call-to-action — not an empty or confusing billing page

## Notes

Use Stripe's hosted Customer Portal for all billing management to avoid PCI scope expansion. Never store raw card data in gotta.cc's database. Billing history should show at least 12 months of invoices. See US-094 for the cancellation flow.
