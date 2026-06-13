---
id: US-051
title: "Browse Blogs on Explore Page"
slug: "browse-blogs-explore"
personas: [P-006, P-001]
epic: "Explore & Discovery"
priority: "must-have"
complexity: "M"
tags: [explore, discovery, browse, blogs]
---

# US-051: Browse Blogs on Explore Page

## User Story

**As a** blog reader and discoverer (P-006),
**I want to** browse a curated explore page of submitted blogs,
**So that** I can find interesting new blogs to follow without knowing exactly what I'm looking for.

## Acceptance Criteria

- [ ] Given I visit /explore, when the page loads, then I see a grid of blog cards showing blog name, niche tag, AI overall score, and avatar/thumbnail
- [ ] Given the explore page loads, when no filters are applied, then blogs are displayed sorted by overall AI score descending by default
- [ ] Given I am on the explore page, when I scroll to the bottom of the page, then the next batch of blogs loads automatically (infinite scroll, 24 cards per page)
- [ ] Given infinite scroll is active, when new cards are loading, then a skeleton loading state is shown at the bottom of the grid
- [ ] Given a blog has a private profile setting, when anyone browses explore, then that blog does not appear in results

## Notes

Core discovery surface for the platform. Blog cards defined in detail in US-057. Infinite scroll behavior must not reset scroll position on back-navigation. See US-052 for search, US-053 for niche filter.
