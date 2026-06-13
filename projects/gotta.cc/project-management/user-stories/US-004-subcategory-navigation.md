---
id: US-004
title: "Subcategory Navigation"
slug: "subcategory-navigation"
personas: [P-001, P-002, P-004]
epic: "Category Browsing"
priority: "must-have"
complexity: "M"
tags: [navigation, subcategories, hierarchy, browsing]
---

# US-004: Subcategory Navigation

## User Story

**As a** Web Nostalgia Explorer (P-001),
**I want to** drill into subcategories from a parent category page,
**So that** I can progressively narrow my exploration to exactly the kind of sites I am looking for.

## Acceptance Criteria

- [ ] Given I am on a category page that has subcategories, when I view the page, then I see subcategory cards showing name, icon, and site count.
- [ ] Given I click a subcategory card, when the navigation completes, then I land on that subcategory's own page with the same layout pattern.
- [ ] Given a subcategory has no sites yet, when I view that card, then it is visually indicated as "coming soon" or "0 sites" rather than hidden entirely.

## Notes

Empty subcategories should remain visible to communicate the directory's scope and invite submissions (links to submission flow). Depth should support at least 3 levels of nesting (e.g., Technology → Web Development → Static Site Generators).
