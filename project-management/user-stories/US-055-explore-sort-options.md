---
id: US-055
title: "Sort Explore Results"
slug: "explore-sort-options"
personas: [P-006, P-001]
epic: "Explore & Discovery"
priority: "should-have"
complexity: "S"
tags: [explore, sort, discovery, ranking]
---

# US-055: Sort Explore Results

## User Story

**As a** blog reader and discoverer (P-006),
**I want to** sort explore results by different criteria,
**So that** I can find either the highest-quality blogs, the newest submissions, or the most trending content depending on what I'm after.

## Acceptance Criteria

- [ ] Given I am on /explore, when I open the sort dropdown, then I see options: "Top Scored," "Newest," "Most Improved," and "Trending"
- [ ] Given I select "Newest," when results reorder, then blogs are sorted by submission date descending
- [ ] Given I select "Most Improved," when results reorder, then blogs are sorted by the largest positive score delta over the last 30 days
- [ ] Given I select "Trending," when results reorder, then blogs are sorted by a composite of recent score activity and reader interactions in the last 7 days
- [ ] Given I select any sort option, when the page URL updates, then the selected sort is stored in `?sort=` so the sorted view is shareable

## Notes

Default sort is "Top Scored." "Trending" algorithm is a weighted composite — define exact formula with engineering before implementation. Sort composes with all active filters (US-052, US-053, US-054).
