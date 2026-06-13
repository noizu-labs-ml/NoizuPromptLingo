---
id: US-027
title: "Filter Competitions by Niche"
slug: "filter-competitions-by-niche"
personas: [P-001, P-002, P-007]
epic: "Competition Browsing"
priority: "must-have"
complexity: "M"
tags: [competitions, browsing, filter, niche, discovery]
---

# US-027: Filter Competitions by Niche

## User Story

**As a** niche blogger (P-001),
**I want to** filter competitions by content category/niche,
**So that** I can find competitions that are relevant to my blog's topic and increase my chances of winning.

## Acceptance Criteria

- [ ] Given I am on the Competitions page, when I open the niche filter, then I see a list of available categories (e.g., Lifestyle, Tech, Food, Travel, Finance, Health, DIY, Parenting, Fashion, Gaming)
- [ ] Given I select one or more niches, when the filter is applied, then only competitions matching those niches are displayed and the active filter count is shown
- [ ] Given I combine niche filter with a status filter, when both are applied, then results satisfy both conditions simultaneously
- [ ] Given no competitions exist for my selected niche, when the filter is applied, then an empty state message suggests broadening my filters or notifying me when new competitions are added
- [ ] Given I am a returning user, when I visit the Competitions page, then my last-used niche filter is remembered via localStorage or user preference
- [ ] Given a competition has multiple eligible niches, when I filter by any of those niches, then the competition appears in results

## Notes

Niche taxonomy should align with the same categories used for blog scoring/discovery. Multi-select should be supported. Related to US-026 (status filter) and US-045 (leaderboard niche filter). SEO bloggers like P-007 will use this heavily to find niche-specific competitions for link-building opportunities.
