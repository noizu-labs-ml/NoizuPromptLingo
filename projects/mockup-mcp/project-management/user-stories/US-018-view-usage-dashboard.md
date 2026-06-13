---
id: US-018
title: "View usage dashboard after first session"
slug: "view-usage-dashboard"
personas: [P-001, P-002, P-004]
epic: "Onboarding & Authentication"
priority: "should-have"
complexity: "M"
tags: [dashboard, usage, analytics, quota, billing]
---

# US-018: View usage dashboard after first session

## User Story

**As a** startup founder (P-004),
**I want to** see a usage dashboard showing my generation activity, quota consumption, and recent mockups,
**So that** I can understand my usage patterns and anticipate when I'll need to upgrade my plan.

## Acceptance Criteria

- [ ] Given at least one successful MCP tool call, when I navigate to the Dashboard, then I see total requests this billing period, tokens consumed, and remaining quota as a percentage
- [ ] Given I have multiple API keys, when I view the dashboard, then usage is broken down per key so I can identify which environment is consuming quota
- [ ] Given I am approaching 80% of my quota, when I view the dashboard, then a highlighted warning prompts me to upgrade before hitting the limit
- [ ] Given I click on a recent mockup thumbnail on the dashboard, when the detail view opens, then I see the prompt, generation parameters, and a link to the mockup in the gallery (US-019)

## Notes

Dashboard data is refreshed every 5 minutes; real-time streaming is not required for MVP. Quota reset date must be visible. Related to US-019, and billing/plan management stories (future epic).
