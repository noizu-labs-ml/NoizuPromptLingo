---
id: US-007
title: "Surprise Me — Random Category"
slug: "surprise-me-category"
personas: [P-001, P-004]
epic: "Category Browsing"
priority: "should-have"
complexity: "S"
tags: [discovery, random, surprise, exploration]
---

# US-007: Surprise Me — Random Category

## User Story

**As a** Casual Link-Follower (P-004),
**I want to** click a "Surprise Me" button that drops me into a random category,
**So that** I can explore the directory serendipitously without needing to decide where to start.

## Acceptance Criteria

- [ ] Given I am on any page, when I click the "Surprise Me" button in the navigation, then I am taken to a randomly selected category page that has at least one live site.
- [ ] Given I click "Surprise Me" multiple times in a session, when each click fires, then I am not taken to the same category twice in a row.
- [ ] Given the random category page loads, when I arrive, then a dismissible banner reads "You were surprised! Explore or keep going →" with a second Surprise Me trigger.

## Notes

Serendipitous navigation is a core differentiator vs. search-first tools. This feature is the category-level equivalent of US-021 (random site). Empty or stub categories (0 sites) must be excluded from the random pool.
