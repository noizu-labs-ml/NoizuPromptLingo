---
id: US-098
title: "Mobile Responsive Category Browsing"
slug: "mobile-responsive-category-browsing"
personas: [P-004, P-001]
epic: "Accessibility & Performance"
priority: "must-have"
complexity: "M"
tags: [mobile, responsive, ux, category, browsing, performance]
---

# US-098: Mobile Responsive Category Browsing

## User Story

**As a** Casual Link-Follower (P-004),
**I want to** browse categories and listings comfortably on my phone,
**So that** I can discover interesting sites during commutes or idle moments without pinching and zooming.

## Acceptance Criteria

- [ ] Given I visit gotta.cc on a mobile device (viewport width ≤ 480px), when any category page loads, then the layout is single-column with no horizontal overflow or clipped content
- [ ] Given the category tree is displayed on mobile, when I tap a category, then the subcategory list expands inline below the tapped item (accordion pattern) rather than requiring a sidebar interaction
- [ ] Given I am browsing a listing card on mobile, when I view it, then the site title, description, and composite score are visible without scrolling horizontally — the five-dimension breakdown collapses to the composite score only, with a "See details" tap to expand
- [ ] Given I tap a listing's external link on mobile, when the link opens, then it opens in a new tab/window so I retain my position in the directory
- [ ] Given the page is loaded on a mobile device with a slow connection (simulated 3G), when the content loads, then the core listing data (title, URL, score) renders before images or chart data, using skeleton loading states

## Notes

The accordion category tree on mobile is a significant interaction change from the desktop sidebar pattern — ensure the collapsed/expanded state persists within a session so users don't lose their place. Connect skeleton loading to US-099 (graceful degradation on slow connections). Test on both iOS Safari and Android Chrome.
