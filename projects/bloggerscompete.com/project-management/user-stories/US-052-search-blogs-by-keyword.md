---
id: US-052
title: "Search Blogs by Keyword"
slug: "search-blogs-by-keyword"
personas: [P-006, P-002]
epic: "Explore & Discovery"
priority: "must-have"
complexity: "M"
tags: [explore, search, keyword, discovery]
---

# US-052: Search Blogs by Keyword

## User Story

**As a** blog reader and discoverer (P-006),
**I want to** search blogs by keyword,
**So that** I can quickly find blogs about a specific topic or written by a blogger I've heard of.

## Acceptance Criteria

- [ ] Given I am on /explore, when I type in the search input, then results filter in real-time with a 300ms debounce
- [ ] Given I enter a search query, when results are returned, then blog name, description, and niche tags are all searched
- [ ] Given a search query returns zero matches, when results render, then I see an empty state message with a suggestion to try broader terms
- [ ] Given I have an active search query, when I clear the input, then the full unfiltered explore grid is restored
- [ ] Given I submit a search, when results load, then the URL updates with a `?q=` parameter so the search is shareable/bookmarkable

## Notes

Search operates client-side against a cached blog index for Free tier responsiveness. Pro users may get full-text search against blog content in a future iteration. See US-051 for the base explore page and US-058 for empty state handling.
