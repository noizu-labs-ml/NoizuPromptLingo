---
id: US-077
title: "Upgrade to Pro Plan"
slug: "upgrade-to-pro"
personas: [P-001, P-002, P-007]
epic: "Billing & Subscription"
priority: "must-have"
complexity: "M"
tags: [billing, subscription, upgrade, stripe, pro]
---

# US-077: Upgrade to Pro Plan

## User Story

**As a** Free-tier blogger who has hit my submission limits (P-001),
**I want to** upgrade to the Pro plan ($12/mo) with a single click,
**So that** I can submit unlimited blogs, enter more competitions, and access detailed AI score breakdowns.

## Acceptance Criteria

- [ ] Given I am on the Free plan, when I click "Upgrade to Pro" anywhere in the app (billing page, upgrade prompts, feature gates), then I am directed to a Stripe Checkout session for the Pro plan.
- [ ] Given I am in Stripe Checkout, when I complete payment with a valid card, then I am redirected to a success page confirming my Pro status and new feature access.
- [ ] Given payment is successful, when I return to the dashboard, then my plan badge reads "Pro" and previously locked features (unlimited submissions, full score breakdown) are immediately accessible.
- [ ] Given I am in Stripe Checkout, when I cancel or close the checkout, then I am returned to the billing page with no charge applied and my Free plan intact.
- [ ] Given payment fails in Stripe Checkout, when the error is returned, then I see a specific error message (e.g., "Card declined — please try another card") and can retry.
- [ ] Given I am already on Pro, when the "Upgrade to Pro" button is encountered, then it is hidden or replaced with "Current Plan."

## Notes

Stripe Checkout should use `mode: subscription` with the Pro price ID. Success/cancel redirect URLs must include session ID for verification. Relates to US-076 (view plan), US-082 (Stripe integration). Feature gating must be enforced server-side, not just client-side.
