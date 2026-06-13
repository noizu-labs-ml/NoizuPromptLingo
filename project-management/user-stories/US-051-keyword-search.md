---
id: US-051
title: "Keyword Search Across Listings"
slug: "keyword-search"
personas: [P-001, P-003, P-004, P-008]
epic: "Search & Filtering"
priority: "must-have"
complexity: "M"
tags: [search, discovery, listings, summaries, tags]
---

# US-051: Keyword Search Across Listings

## User Story

**As a** casual link-follower (P-004),
**I want to** search by keyword across site listings, summaries, and tags,
**So that** I can quickly find quality websites about specific topics without browsing category trees.

## Acceptance Criteria

- [ ] Given the search bar is visible in the header, when I type a keyword and press Enter, then results are displayed ranked by relevance with score badges visible
- [ ] Given a keyword query, when results are returned, then they include matches from site title, editorial summary, and tag fields
- [ ] Given a search is executed, when results load, then each result card shows the site name, one-line summary, overall score, and category path
- [ ] Given a query that matches 0 results, when the results page renders, then an empty-state panel with browse suggestions is shown (see US-058)
- [ ] Given a search result, when I click the listing, then I am taken to the site detail page (not the external URL directly)

## Notes

Full-text search should be scoped to curator-written content (summaries, tags) rather than crawled page content to preserve quality signal. Related stories: US-052 (filter by category), US-057 (autocomplete), US-058 (empty state).
