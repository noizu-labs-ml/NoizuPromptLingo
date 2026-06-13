---
id: US-072
title: "Subscription Tier Selection and Upgrade"
slug: "subscription-tier-selection-upgrade"
personas: [P-008, P-002, P-007, P-006]
epic: "Onboarding & Authentication"
priority: "should-have"
complexity: "XL"
tags: [subscription, billing, upgrade, tiers, payments, saas]
---

# US-072: Subscription Tier Selection and Upgrade

## User Story

**As a** community curator (P-008),
**I want to** select a subscription tier and upgrade my account,
**So that** I can access higher collection limits, API access, and other premium features that match my usage level.

## Acceptance Criteria

- [ ] Given I visit the pricing or upgrade page, when the page loads, then all available tiers are displayed with feature comparison (collection limits, API access, saved searches, export features)
- [ ] Given I select a paid tier, when I click "Upgrade", then I am taken to a payment flow powered by Stripe (or equivalent) where I enter payment details
- [ ] Given payment is successful, when I am returned to the app, then my account tier is updated immediately and the new feature limits are enforced
- [ ] Given I am on a paid tier, when I access account settings, then I can view my current plan, next billing date, and a "Manage billing" link that opens the Stripe customer portal
- [ ] Given my payment fails on renewal, when the billing event occurs, then I receive an email notification and have a grace period of at least 7 days before features are downgraded
- [ ] Given I downgrade from a paid tier, when downgrade is confirmed, then a warning is shown if I have collections or saved searches that exceed the free tier limits, with options to delete or archive excess data

## Notes

This is the primary monetization mechanism for gotta.cc and requires careful implementation of webhook handling for Stripe events (payment succeeded, failed, subscription cancelled). Tier enforcement must be server-side, never trust-client. Related: US-060 (collection limits), US-056 (saved search limits), US-075 (account deletion).
