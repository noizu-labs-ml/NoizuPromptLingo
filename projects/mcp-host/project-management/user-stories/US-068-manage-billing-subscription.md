---
id: US-068
title: "Manage billing and subscription tier"
slug: "manage-billing-subscription"
personas: [P-005, P-006]
epic: "Organization Management"
priority: "should-have"
complexity: "L"
tags: [organization, billing, subscription, tiers, payments]
---

# US-068: Manage Billing and Subscription Tier

## User Story

**As a** Engineering Manager (P-005),
**I want to** manage my organization's billing information and subscription tier,
**So that** I can control costs, upgrade capabilities as my team grows, and ensure our account stays in good standing.

## Acceptance Criteria

- [ ] Given the user is an org admin (US-062), when they navigate to the billing settings page, then it displays: current plan tier, billing period (monthly/annual), next renewal date, payment method on file, and current period usage summary.
- [ ] Given the admin views available plans, when they click "Change plan," then the system presents the tier options (Free, Pro, Enterprise) with feature comparisons including: deployment limits, invocation quotas, team member seats, and support level.
- [ ] Given the admin selects a new plan, when they confirm the change, then the system prorates the billing difference, applies the new limits immediately, and sends a confirmation email with the updated invoice.
- [ ] Given the org is approaching a usage limit (deployments, invocations, seats), when usage reaches 80%, then the system sends a notification to org admins suggesting a plan upgrade or limit increase.
- [ ] Given the admin updates the payment method, when they submit new payment details, then the system validates the payment method, stores it securely via a PCI-compliant payment processor, and uses it for the next billing cycle.
- [ ] Given the org's payment fails on renewal, when the failure occurs, then the system enters a 14-day grace period with continued service, sends daily reminders to admins, and downgrades to the Free tier if payment is not resolved.

## Notes

Billing integration should use Stripe or a similar PCI-compliant provider. Plan tiers map to the roadmap phases: Free (Phase 0 basics), Pro (Phase 1-2 features), Enterprise (Phase 3 multi-tenancy + SLA). Related: US-061, US-062, US-064.
