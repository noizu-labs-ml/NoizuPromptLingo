---
id: US-039
title: "Sort by Hot / New / Top / Controversial"
slug: "sort-hot-new-top-controversial"
personas: [P-001, P-002, P-003, P-005, P-006, P-007, P-008]
epic: "Search & Discovery"
priority: "must-have"
complexity: "M"
tags: [sorting, feed, discovery, ranking]
---

# US-039: Sort by Hot / New / Top / Controversial

## User Story

**As a** community member (P-002),
**I want to** switch between sort modes — Hot, New, Top, and Controversial — when browsing the feed,
**So that** I can choose between trending content, fresh submissions, all-time best, or discussion-sparking posts depending on my intent.

## Acceptance Criteria

- [ ] Given I am on the feed page, when I select "New," then prompts are listed in reverse chronological order by submission date with no score weighting
- [ ] Given I select "Top," when prompts are fetched, then they are ordered by total vote score descending; I can further filter by time range (today, this week, this month, all time)
- [ ] Given I select "Controversial," when prompts are fetched, then they are ranked by a controversy score that surfaces items with high vote counts but close to 50/50 up/down ratio
- [ ] Given I select a sort mode, when the page URL updates, then the selected mode is reflected in the URL so the view is shareable and persists on refresh

## Notes

The controversy score formula should weight total vote volume to surface highly engaged controversial items over low-traffic borderline ones. The selected sort mode should persist across sessions per user preference. Default sort mode for logged-out users is "Hot."
