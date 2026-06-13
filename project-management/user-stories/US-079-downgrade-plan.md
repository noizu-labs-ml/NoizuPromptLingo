---
id: US-079
title: "Downgrade Subscription Plan"
slug: "downgrade-plan"
personas: [P-001, P-002]
epic: "Billing & Subscription"
priority: "should-have"
complexity: "M"
tags: [billing, subscription, downgrade, cancellation]
---

# US-079: Downgrade Subscription Plan

## User Story

**As a** Pro subscriber who no longer needs premium features (P-002),
**I want to** downgrade to a lower plan or cancel my subscription,
**So that** I stop being charged for features I don't use.

## Acceptance Criteria

- [ ] Given I am on Pro or Team, when I click "Change Plan" > "Downgrade," then I see a confirmation modal explaining what features I will lose and when the downgrade takes effect (end of billing cycle).
- [ ] Given I confirm the downgrade, when the current billing cycle ends, then my plan is automatically switched to the target tier and feature access is updated accordingly.
- [ ] Given I downgrade from Team to Free, when the downgrade takes effect, then all team member seats are revoked and members receive an email notification.
- [ ] Given I downgrade from Pro to Free, when the downgrade takes effect, then existing blog submissions are preserved but new submissions are limited to the Free quota.
- [ ] Given I have active competition entries at downgrade time, when the downgrade takes effect, then entries already submitted remain valid for the duration of those competitions.
- [ ] Given I initiate a downgrade but then change my mind, when I click "Keep My Plan" in the confirmation modal or before the cycle ends, then the scheduled downgrade is cancelled.

## Notes

Downgrade should be scheduled via Stripe's subscription schedule API, not applied immediately. Data preservation policy: historical scores and submissions are never deleted on downgrade. Relates to US-076, US-077, US-078.
