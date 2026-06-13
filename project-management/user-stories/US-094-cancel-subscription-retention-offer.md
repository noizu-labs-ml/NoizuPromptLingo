---
id: US-094
title: "Cancel Subscription with Retention Offer"
slug: "cancel-subscription-retention-offer"
personas: [P-001, P-002]
epic: "Monetization & Subscriptions"
priority: "should-have"
complexity: "M"
tags: [billing, cancellation, retention, churn, subscription]
---

# US-094: Cancel Subscription with Retention Offer

## User Story

**As a** Web Nostalgia Explorer (P-001),
**I want to** cancel my subscription easily if I choose to,
**So that** I feel safe subscribing knowing I am not locked in — which makes me more likely to subscribe in the first place.

## Acceptance Criteria

- [ ] Given I am a paying subscriber and I click "Cancel Subscription" in billing settings, when the cancellation flow begins, then I am shown a brief summary of what I will lose access to when the subscription ends
- [ ] Given the cancellation summary is shown, when I indicate my cancellation reason (from a short dropdown), then a contextual retention offer is presented — e.g., a one-month pause option or a discount on renewal
- [ ] Given I accept the retention offer (pause or discount), when I confirm, then my subscription is not cancelled and the offer terms are applied and displayed on my billing page
- [ ] Given I decline the retention offer and confirm cancellation, when the cancellation is processed, then my subscription remains active until the end of the current billing period and I receive a confirmation email
- [ ] Given my subscription has lapsed after cancellation, when I log in, then I am gracefully downgraded to the free tier with my data intact — no content is deleted

## Notes

Make cancellation frictionless — dark patterns erode trust and gotta.cc's brand is built on trustworthiness. The retention offer should be genuine value (a real pause option or a real discount), not a UI trap. Data preservation on downgrade is essential: collections, saved sites, and listing claims must survive the tier change.
