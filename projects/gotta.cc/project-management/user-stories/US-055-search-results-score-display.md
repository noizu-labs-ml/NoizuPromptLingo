---
id: US-055
title: "Search Results with Score Display"
slug: "search-results-score-display"
personas: [P-001, P-003, P-004, P-008]
epic: "Search & Filtering"
priority: "must-have"
complexity: "M"
tags: [search, results, score, ui, cards]
---

# US-055: Search Results with Score Display

## User Story

**As a** web nostalgia explorer (P-001),
**I want to** see quality scores displayed on every search result card,
**So that** I can assess trustworthiness and depth at a glance before clicking through.

## Acceptance Criteria

- [ ] Given search results are returned, when the results page renders, then each result card shows overall score as a numeric badge (e.g., "84/100") and a visual indicator (color band or star equivalent)
- [ ] Given a result card, when I hover over the overall score badge, then a tooltip breaks down the five dimension scores (originality, depth, freshness, human authorship, design quality)
- [ ] Given results are displayed, when I change sort order to "Score (high to low)", then cards re-order by overall score without re-executing the search
- [ ] Given results are displayed, when I sort by "Relevance" (default), then ranking blends keyword match strength with quality score
- [ ] Given a result card is rendered, when it is displayed on mobile, then score badge is visible without requiring hover (tap-to-expand breakdown)

## Notes

Score badges should use a consistent color palette: green (80+), yellow (60-79), orange (40-59), red (<40). This display pattern must be consistent with category browse pages and collection views. Related: US-051 (keyword search), US-052 (category filter).
