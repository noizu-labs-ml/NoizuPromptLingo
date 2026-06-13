---
id: US-076
title: "View Current Subscription Plan"
slug: "view-current-plan"
personas: [P-001, P-002, P-003]
epic: "Billing & Subscription"
priority: "must-have"
complexity: "S"
tags: [billing, subscription, account, dashboard]
---

# US-076: View Current Subscription Plan

## User Story

**As a** registered blogger (P-001),
**I want to** view my current subscription plan, usage limits, and renewal date in my account settings,
**So that** I know what features I have access to and when I'll be billed next.

## Acceptance Criteria

- [ ] Given I am logged in, when I navigate to Account > Billing, then I see my current plan name (Free, Pro, or Team), monthly cost, and renewal date.
- [ ] Given I am on the Free plan, when I view billing, then I see usage counters for blog submissions (X/1 used) and competition entries (X/3 used) for the current month.
- [ ] Given I am on the Pro plan, when I view billing, then I see my $12/mo charge, next billing date, and a badge confirming active status.
- [ ] Given I am on the Team plan, when I view billing, then I see the $29/mo charge, number of seats used (X/5), and the team owner's name.
- [ ] Given my subscription is in a grace period (payment failed), when I view billing, then a prominent warning banner displays with a "Update Payment Method" CTA.
- [ ] Given any plan, when I view billing, then a "Change Plan" button is visible and accessible.

## Notes

Relates to US-077 (upgrade to Pro), US-078 (upgrade to Team), US-079 (downgrade). The billing page should use Stripe Customer Portal data where possible to avoid storing sensitive payment info locally.
