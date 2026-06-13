---
id: US-090
title: "Upgrade to Supporter Tier ($5/mo)"
slug: "upgrade-supporter-tier"
personas: [P-001, P-004, P-008]
epic: "Monetization & Subscriptions"
priority: "must-have"
complexity: "L"
tags: [monetization, subscription, billing, supporter, stripe]
---

# US-090: Upgrade to Supporter Tier ($5/mo)

## User Story

**As a** Web Nostalgia Explorer (P-001),
**I want to** upgrade to the Supporter tier for $5/month,
**So that** I can access premium features like ad-free browsing, custom collections, and the satisfaction of sustaining the directory I love.

## Acceptance Criteria

- [ ] Given I am on the pricing page or an upgrade prompt, when I click "Become a Supporter," then I am taken to a checkout flow powered by Stripe with the $5/month plan pre-selected
- [ ] Given I complete the Stripe checkout, when payment is confirmed, then my account is immediately upgraded to Supporter tier and I see a confirmation message with a list of unlocked features
- [ ] Given I am a Supporter, when I browse any category page, then no sponsored placements or promotional banners are displayed
- [ ] Given I am a Supporter, when I create a collection, then I can create up to 20 collections (vs. 3 on the free tier)
- [ ] Given the payment fails (e.g., expired card), when Stripe notifies gotta.cc via webhook, then I receive an email with a link to update my payment method and my account remains active for a 7-day grace period

## Notes

Stripe is the assumed payment processor. The grace period on failed payments reduces involuntary churn. Feature gating must be enforced server-side — never rely on client-side checks for premium feature access. See US-093 (manage billing) and US-094 (cancel with retention offer).
