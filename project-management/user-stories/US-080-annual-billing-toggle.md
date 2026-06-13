---
id: US-080
title: "Toggle Annual Billing for Discount"
slug: "annual-billing-toggle"
personas: [P-001, P-002, P-003]
epic: "Billing & Subscription"
priority: "could-have"
complexity: "M"
tags: [billing, annual, discount, subscription, pricing]
---

# US-080: Toggle Annual Billing for Discount

## User Story

**As a** committed blogger considering Pro or Team (P-002),
**I want to** switch to annual billing and receive a discounted rate,
**So that** I save money compared to paying monthly.

## Acceptance Criteria

- [ ] Given I am on the pricing page or upgrade flow, when I toggle "Annual" (vs "Monthly"), then the displayed price updates to reflect the annual rate (e.g., Pro: $10/mo billed annually = $120/yr vs $144/yr monthly).
- [ ] Given I select an annual plan, when I complete Stripe Checkout, then I am billed the full annual amount upfront and my subscription period is set to 12 months.
- [ ] Given I am on a monthly Pro plan, when I navigate to billing settings and switch to Annual, then I see the prorated credit and new annual charge before confirming.
- [ ] Given annual billing is active, when I view the billing page, then it clearly states "Annual plan — renews {date}" and shows the per-month equivalent cost.
- [ ] Given I am on an annual plan and request a downgrade, when I confirm, then the system informs me that no refund is issued for unused months per the stated refund policy.
- [ ] Given the annual toggle, when it is in the "Annual" state, then a savings badge (e.g., "Save 17%") is displayed prominently.

## Notes

Requires two Stripe price IDs per plan (monthly + annual). Discount percentages: Pro ~17% (10/mo annual vs 12/mo), Team ~14% (25/mo annual vs 29/mo) — exact values TBD with product. Relates to US-077, US-078, US-082.
