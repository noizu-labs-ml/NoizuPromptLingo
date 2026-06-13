---
id: US-048
title: "Generation Cost Tracking"
slug: "generation-cost-tracking"
personas: [P-005, P-006, P-003]
epic: "Generation Engine"
priority: "should-have"
complexity: "M"
tags: [generation, cost, tokens, billing, usage, admin]
---

# US-048: Generation Cost Tracking

## User Story

**As a** price-sensitive hobbyist worldbuilder (P-005),
**I want to** see how many generation credits or tokens each generation consumes, and track my total usage,
**So that** I can manage my spending and avoid unexpected charges.

## Acceptance Criteria

- [ ] Given a generation request completes, when I view the draft, then a metadata label shows the number of tokens consumed (input + output) and the equivalent credit cost.
- [ ] Given I navigate to Account Settings, when I open the Usage section, then I see a monthly breakdown of total generation tokens consumed, organized by universe.
- [ ] Given I am approaching my plan's monthly generation limit, when usage reaches 80%, then I receive an in-app warning notification.
- [ ] Given I submit a generation with a known source list, when the cost estimate is computed, then a pre-generation cost estimate (tokens) is shown before I confirm submission.
- [ ] Given I am the platform admin (P-006), when I view the admin panel, then I can see aggregate generation usage across all users, broken down by plan tier.

## Notes

Depends on US-036. Token usage data should be stored per generation event in the generation history (US-045). Pre-generation cost estimation requires knowing the prompt length, source context size, and expected output length — this is an estimate, not a guarantee. Related: US-041 (bulk generation), US-045.
