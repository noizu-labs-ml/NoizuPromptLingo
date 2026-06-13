---
id: US-081
title: "Space Discovery with Filters"
slug: "space-discovery-filters"
personas: [P-004, P-007]
epic: "Explore & Homepage"
priority: "should-have"
complexity: "M"
tags: [discovery, spaces, filtering]
---

# US-081: Space Discovery with Filters

## User Story

**As a** Startup Founder (P-007),
**I want to** filter and search for spaces by topic, member count, and activity level,
**So that** I can find relevant communities for my specific interests and join high-quality, active spaces.

## Acceptance Criteria

- [ ] Given I'm on the "Explore Spaces" page, when I see the filter sidebar, then I can filter by: topic tags, member count range, activity level (last 24h, 7 days, 30 days)
- [ ] Given I select "AI/ML" topic tag and "100-1000 members", when I apply filters, then results show only AI/ML spaces with 100-1000 members
- [ ] Given I search for "prompt engineering", when I enter the query, then results show spaces with names or descriptions matching the search term
- [ ] Given filters return no results, when I view the page, then I see an empty state with "No spaces match your filters" and a button to reset filters
- [ ] Given I have active filters, when I navigate away and return, then my filter selections are preserved

## Notes

Filters should be additive (AND logic). Member count buckets: <50, 50-100, 100-500, 500-1K, 1K-10K, >10K.