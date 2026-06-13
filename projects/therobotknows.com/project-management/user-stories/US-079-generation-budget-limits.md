---
id: US-079
title: "Generation Budget & Usage Limits"
slug: "generation-budget-limits"
personas: [P-001, P-003, P-005, P-006]
epic: "Settings & Preferences"
priority: "must-have"
complexity: "M"
tags: [settings, billing, limits, ai, budget, usage]
---

# US-079: Generation Budget & Usage Limits

## User Story

**As a** user managing my AI generation costs (P-001, P-003, P-005),
**I want to** set a monthly generation budget and receive alerts as I approach it,
**So that** I never receive an unexpected bill and can plan my worldbuilding sessions accordingly.

## Acceptance Criteria

- [ ] Given I am on Settings > AI > Budget, when I set a monthly token or credit limit, then the system enforces that limit and blocks generation requests once it is reached.
- [ ] Given I have set a budget limit, when I reach 75% of the limit, then I receive an in-app notification and email warning.
- [ ] Given I have set a budget limit, when I reach 100%, then generation requests are blocked and a banner with an upgrade/reset option is displayed.
- [ ] Given I am viewing the Settings > AI > Budget page, when I look at my usage meter, then I see current-period consumption, remaining budget, and a breakdown by universe.
- [ ] Given my budget resets at the start of a new billing period, when the reset occurs, then my generation access is automatically restored and I receive a confirmation notification.

## Notes

Depends on US-078 (AI model selection). Related: US-086 (admin billing management). Budget enforcement must be near-real-time — generation jobs should check remaining budget before dispatching to the AI provider.
