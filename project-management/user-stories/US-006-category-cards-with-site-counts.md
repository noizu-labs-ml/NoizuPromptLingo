---
id: US-006
title: "Category Cards with Site Counts"
slug: "category-cards-with-site-counts"
personas: [P-001, P-004, P-002]
epic: "Category Browsing"
priority: "should-have"
complexity: "S"
tags: [categories, cards, site-count, homepage]
---

# US-006: Category Cards with Site Counts

## User Story

**As a** Web Nostalgia Explorer (P-001),
**I want to** see how many sites are listed in each category directly on the category card,
**So that** I can gauge the richness of each section before clicking into it.

## Acceptance Criteria

- [ ] Given I am viewing a list of categories (homepage or parent category page), when the page loads, then each category card displays a site count badge.
- [ ] Given a category has zero listed sites, when I view its card, then the count reads "0 sites" rather than being hidden.
- [ ] Given the site count changes (new site added/removed), when the category page next loads, then the count reflects the current total within acceptable cache freshness (≤1 hour stale).

## Notes

Site counts set user expectations before clicking. This prevents frustration when entering sparse categories. Counts should reflect only approved/live sites, not pending submissions.
