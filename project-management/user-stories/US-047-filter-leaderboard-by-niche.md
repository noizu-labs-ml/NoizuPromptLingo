---
id: US-047
title: "Filter Leaderboard by Niche Category"
slug: "filter-leaderboard-by-niche"
personas: [P-001, P-002, P-006, P-007]
epic: "Leaderboards"
priority: "must-have"
complexity: "M"
tags: [leaderboard, filter, niche, category, discovery, rankings]
---

# US-047: Filter Leaderboard by Niche Category

## User Story

**As a** lifestyle blogger who wants to track my niche-specific ranking (P-001),
**I want to** filter the leaderboard to show only blogs in my niche category,
**So that** I can see a meaningful ranking against bloggers in the same space rather than being compared to tech or finance bloggers.

## Acceptance Criteria

- [ ] Given I am on the Leaderboard page, when I open the niche filter, then I see the same category list used elsewhere on the platform (Lifestyle, Tech, Food, Travel, Finance, Health, DIY, Parenting, Fashion, Gaming, and an "All Niches" default)
- [ ] Given I select a specific niche, when the filter is applied, then only blogs tagged with that niche are shown and the leaderboard rankings restart from #1 within that niche
- [ ] Given I combine a niche filter with a period filter (US-046), when both are active, then the leaderboard shows niche-specific rankings for the selected time period
- [ ] Given my blog is registered in a niche, when I select that niche filter, then my blog row is highlighted regardless of which page of results it appears on
- [ ] Given a niche has fewer than 10 registered blogs, when I filter to that niche, then an informational notice shows the limited pool size to provide context for the rankings
- [ ] Given I am a blog reader (P-006) looking for quality blogs to follow, when I filter by a niche I enjoy reading, then I discover the top-ranked blogs in that niche with links to their profiles

## Notes

Niche leaderboards are a key discovery mechanism for readers (P-006) and a motivator for niche bloggers (P-001) who may rank lower globally but are top-5 in their category. Niche filter should persist when switching between time period tabs. Related to US-045 (global leaderboard), US-046 (period filter), US-027 (competition niche filter).
