---
id: US-009
title: "Choose Subscription Tier"
slug: "choose-subscription-tier"
personas: [P-002, P-005, P-006]
epic: "Onboarding & Authentication"
priority: "could-have"
complexity: "L"
tags: [subscription, billing, monetization, pricing]
---

# US-009: Choose Subscription Tier

## User Story

**As a** user evaluating the platform for individual or organizational use (P-002, P-005, P-006),
**I want to** select between free, pro, and enterprise subscription tiers,
**So that** I gain access to the feature set appropriate for my budget and use case.

## Acceptance Criteria

- [ ] Given I am in the onboarding wizard or account settings, when I view the pricing page, then I see a clear comparison of free, pro, and enterprise tiers with feature gates explicitly listed
- [ ] Given I select the pro tier, when I complete payment via Stripe, then my account is upgraded immediately and pro-gated features (bulk export, API access, advanced filtering) become available
- [ ] Given I am on the free tier, when I attempt to access a pro-gated feature, then I see an upgrade prompt with the specific feature highlighted on the pricing comparison
- [ ] Given I select enterprise, when I submit the inquiry form, then a confirmation email is sent and the sales workflow is triggered outside the self-serve flow

## Notes

Free tier grants access to public catalog browsing, basic search, and read-only technique pages. Enterprise tier requires a sales-assisted flow. Stripe integration is a prerequisite; depends on payment infrastructure setup.
