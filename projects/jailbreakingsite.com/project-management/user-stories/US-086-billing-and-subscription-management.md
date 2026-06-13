---
id: US-086
title: "View Billing and Subscription Management"
slug: "billing-and-subscription-management"
personas: [P-002, P-005]
epic: "Settings & Administration"
priority: "should-have"
complexity: "M"
tags: [settings, billing, subscription, payments]
---

# US-086: View Billing and Subscription Management

## User Story

**As a** decision-maker responsible for tool procurement (P-002, P-005),
**I want to** view my current subscription plan, usage, and billing history and upgrade or cancel from a self-serve interface,
**So that** I can manage costs and justify spend without opening a sales ticket for routine billing actions.

## Acceptance Criteria

- [ ] Given I navigate to "Settings > Billing", then I see my current plan name, billing cycle, next renewal date, and the features included at my tier
- [ ] Given my current plan, when I view usage, then I see consumed vs. available scan credits, API call counts, and seat utilization for the current billing period
- [ ] Given I want to upgrade, when I click "Upgrade Plan" and select a tier, then I am shown a prorated cost preview before confirming
- [ ] Given a payment method on file, when I complete an upgrade, then the new tier is activated immediately and the invoice is sent to the billing email
- [ ] Given I want to cancel, when I click "Cancel Subscription", then I am shown what I will lose and a retention offer before a final confirmation step
- [ ] Given billing history, when I view past invoices, then each entry shows date, amount, plan, and a "Download PDF" link

## Notes

Payment processing via Stripe; PCI scope is fully delegated to Stripe Checkout and Billing Portal where possible. VAT/GST collection and display must comply with user's jurisdiction. Trial expiry should trigger a 7-day, 3-day, and 1-day reminder sequence.
