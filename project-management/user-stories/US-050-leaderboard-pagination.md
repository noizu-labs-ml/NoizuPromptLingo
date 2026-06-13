---
id: US-050
title: "Leaderboard Pagination"
slug: "leaderboard-pagination"
personas: [P-001, P-004, P-006]
epic: "Leaderboards"
priority: "should-have"
complexity: "S"
tags: [leaderboard, pagination, performance, navigation, ux]
---

# US-050: Leaderboard Pagination

## User Story

**As a** blogger ranked outside the top 25 (P-004),
**I want to** paginate through the full leaderboard,
**So that** I can find my rank, browse lower-ranked blogs, and understand the full competitive landscape of the platform.

## Acceptance Criteria

- [ ] Given the leaderboard has more than 25 blogs, when the page renders, then pagination controls are shown at the bottom with Previous / Next buttons and page number indicators
- [ ] Given I click "Next Page," when the next set of 25 results loads, then the page updates without a full reload, the URL updates with a `?page=N` query parameter, and scroll position resets to the top of the leaderboard table
- [ ] Given I am on page 3 and I reload the page, when the page loads, then I land directly on page 3 (URL-based pagination is preserved)
- [ ] Given my blog is on page 4, when I first land on the leaderboard (any page), then a sticky "Jump to My Rank" button is visible that scrolls or navigates to my blog's position
- [ ] Given the total number of blogs is known, when pagination controls render, then the total page count and total blog count are displayed (e.g., "Page 2 of 14 — 342 blogs")
- [ ] Given I navigate to a page beyond the valid range (e.g., page 999), when the page loads, then I am redirected to the last valid page with an informational notice

## Notes

Pagination page size of 25 balances performance and usability. Infinite scroll was considered but rejected — URL-based pagination allows sharing specific pages and is better for accessibility. The "Jump to My Rank" feature requires server knowledge of the current user's rank page offset. Related to US-045 (global leaderboard), US-046 (period filter), US-047 (niche filter). Filters should reset to page 1 when changed.
