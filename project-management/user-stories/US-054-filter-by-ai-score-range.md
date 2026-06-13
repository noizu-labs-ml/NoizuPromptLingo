---
id: US-054
title: "Filter Blogs by AI Score Range"
slug: "filter-by-ai-score-range"
personas: [P-006, P-002]
epic: "Explore & Discovery"
priority: "should-have"
complexity: "M"
tags: [explore, filter, ai-score, quality, discovery]
---

# US-054: Filter Blogs by AI Score Range

## User Story

**As a** blog reader and discoverer (P-006),
**I want to** filter explore results by minimum AI quality score,
**So that** I can surface only high-quality blogs that meet my standard and avoid low-effort content.

## Acceptance Criteria

- [ ] Given I am on /explore, when I open the score filter, then I see a dual-handle range slider with min/max set to 0–100
- [ ] Given I set a minimum score threshold, when the filter applies, then only blogs with an overall AI score at or above that threshold appear
- [ ] Given I set both a min and max score, when results render, then only blogs whose overall score falls within that range are displayed
- [ ] Given the score filter is active, when I hover a blog card, then the card shows the exact overall score so I can verify it meets my filter
- [ ] Given I navigate away and return to /explore, when the page restores from URL params, then the score filter is reapplied from `?score_min=` and `?score_max=` params

## Notes

Score range applies to the overall AI score (0–100), which is the weighted average of all 6 dimension scores. Composable with keyword search (US-052) and niche filter (US-053). Consider preset buttons ("Top 25%", "Top 10%") as a future enhancement.
