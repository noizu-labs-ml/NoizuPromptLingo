---
id: US-057
title: "Blog Card Grid with Infinite Scroll"
slug: "blog-card-grid"
personas: [P-006, P-001]
epic: "Explore & Discovery"
priority: "must-have"
complexity: "M"
tags: [explore, blog-card, grid, infinite-scroll, ui]
---

# US-057: Blog Card Grid with Infinite Scroll

## User Story

**As a** blog reader and discoverer (P-006),
**I want to** see blogs presented in a clean card grid with key details visible at a glance,
**So that** I can quickly evaluate whether a blog is worth visiting without clicking into each one.

## Acceptance Criteria

- [ ] Given the explore grid renders, when a blog card displays, then it shows: blog thumbnail/avatar, blog name, blogger name, niche tag(s), overall AI score badge, and a short description (truncated to 2 lines)
- [ ] Given the grid renders on desktop, when the viewport is ≥1280px, then 4 cards display per row; at 768–1279px, 3 cards; below 768px, 1 card full-width
- [ ] Given I click a blog card, when the navigation fires, then I am taken to that blog's public profile page
- [ ] Given infinite scroll is triggered (user scrolls within 200px of bottom), when the next page is fetching, then a row of skeleton cards appears and disappears when real cards load
- [ ] Given a blog has no thumbnail set, when the card renders, then a generated placeholder with the blog's initials and brand color is shown
- [ ] Given I have loaded multiple pages via infinite scroll, when I click a card and return via back button, then my scroll position is preserved

## Notes

Scroll position preservation requires storing position in session state or using browser scroll restoration. Score badge color: green ≥ 80, yellow 60–79, red < 60. Cards used in explore (US-051), competition leaderboards, and search results — build as a shared component.
