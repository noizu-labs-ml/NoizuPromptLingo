---
id: US-056
title: "Niche Tag Cloud on Explore Page"
slug: "niche-tag-cloud"
personas: [P-006, P-004]
epic: "Explore & Discovery"
priority: "could-have"
complexity: "S"
tags: [explore, tag-cloud, niche, discovery, visual]
---

# US-056: Niche Tag Cloud on Explore Page

## User Story

**As a** new blogger (P-004),
**I want to** see a visual tag cloud of blog niches on the explore page,
**So that** I can quickly understand what categories are most popular and jump into a niche that interests me.

## Acceptance Criteria

- [ ] Given I visit /explore, when the page loads, then a tag cloud is displayed above the blog grid showing all active niche categories
- [ ] Given the tag cloud renders, when I view it, then niche tags are sized proportionally to the number of blogs in that niche (larger = more blogs)
- [ ] Given I click a niche tag in the cloud, when the action fires, then the niche filter (US-053) is activated for that tag and the grid filters immediately
- [ ] Given the explore page has an active niche filter, when the tag cloud renders, then the active niche tag(s) are visually highlighted/selected
- [ ] Given the tag cloud is displayed on mobile, when the viewport is narrow, then the cloud reflows into a horizontally scrollable tag strip

## Notes

Tag cloud is a visual shortcut to the niche filter (US-053) — they share state. Font size range: 12px (smallest niche) to 28px (largest niche). Consider animating tag entry for delight. Low priority relative to grid and filter functionality.
