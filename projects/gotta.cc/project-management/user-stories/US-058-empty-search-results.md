---
id: US-058
title: "Empty Search Results with Browse Suggestions"
slug: "empty-search-results"
personas: [P-004, P-001, P-002]
epic: "Search & Filtering"
priority: "should-have"
complexity: "S"
tags: [search, empty-state, discovery, ux, suggestions]
---

# US-058: Empty Search Results with Browse Suggestions

## User Story

**As a** casual link-follower (P-004),
**I want to** see helpful alternatives when my search returns no results,
**So that** I am not left at a dead end and can still discover something interesting.

## Acceptance Criteria

- [ ] Given a search query returns zero results, when the empty state is displayed, then a message confirms no results were found with the exact query shown
- [ ] Given the empty state is shown, when it renders, then 3–5 category links related to the query terms are suggested (derived from tag similarity)
- [ ] Given the empty state is shown, when it renders, then a "Browse all categories" link is prominently displayed
- [ ] Given the empty state is shown, when it renders, then a "Submit a site" CTA is shown encouraging users to contribute a site matching their search (links to US-026 submission flow)
- [ ] Given the empty state, when the user is not logged in, then suggestions do not require authentication to follow

## Notes

Empty state is an opportunity for retention, not just error handling. The "Submit a site" CTA directly converts search failure into community contribution. Related: US-051 (keyword search), US-057 (autocomplete to prevent empty searches).
