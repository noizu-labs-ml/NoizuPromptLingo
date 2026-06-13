---
id: US-038
title: "Competition Entry Limits (Free vs Pro)"
slug: "competition-entry-limits-free-vs-pro"
personas: [P-001, P-002, P-004]
epic: "Competition Entry"
priority: "must-have"
complexity: "M"
tags: [competitions, entry, limits, monetization, free-tier, pro]
---

# US-038: Competition Entry Limits (Free vs Pro)

## User Story

**As a** free-tier blogger who wants to compete (P-004),
**I want to** understand how many competitions I can enter on my current plan,
**So that** I can decide whether to upgrade to Pro for more competitive opportunities.

## Acceptance Criteria

- [ ] Given I am on the Free tier, when I view the Competitions page, then a banner or sidebar widget shows my remaining competition entries for the current month (e.g., "1 of 2 monthly entries used")
- [ ] Given I am a Free-tier user who has used all monthly competition entries, when I attempt to enter a new competition, then I see a paywall modal showing the Pro plan's entry limit and an upgrade CTA
- [ ] Given I am a Pro user, when I view the Competitions page, then my monthly competition entry allowance is shown (e.g., "5 entries remaining this month")
- [ ] Given I am a Team-tier user, when I view the Competitions page, then my entry allowance reflects Team plan limits and shows entries across team blogs if applicable
- [ ] Given a new billing period starts, when I return to the Competitions page, then my entry counter resets to the plan's monthly limit automatically
- [ ] Given I am close to my entry limit (1 remaining), when I view the Competitions page, then a subtle nudge prompts me to consider upgrading to Pro for more entries

## Notes

Entry limits are a core monetization mechanism. Free: 2 competition entries/month. Pro: 10 entries/month. Team: 25 entries/month (across team). These numbers should be configurable in admin settings. Related to US-032 (entry flow), US-037 (withdrawal and slot restoration). Upgrade prompts should be informative, not alarming.
