---
id: US-009
title: "Mobile-Friendly Category Navigation"
slug: "mobile-category-nav"
personas: [P-004, P-001]
epic: "Category Browsing"
priority: "must-have"
complexity: "M"
tags: [mobile, navigation, responsive, categories]
---

# US-009: Mobile-Friendly Category Navigation

## User Story

**As a** Casual Link-Follower (P-004),
**I want to** browse categories comfortably on my phone,
**So that** I can explore the directory during downtime without pinching, zooming, or fighting tiny tap targets.

## Acceptance Criteria

- [ ] Given I am on a mobile device (viewport <768px), when I view the homepage category list, then categories are displayed as full-width tappable cards with adequate touch target size (≥44px height).
- [ ] Given I am deep in the category tree on mobile, when I tap the navigation menu, then a slide-in drawer shows the category tree with clear back/up affordances.
- [ ] Given I am on a category page on mobile, when I scroll, then subcategory cards reflow to a single-column layout and the breadcrumb remains accessible.

## Notes

Mobile is likely the primary browsing context for P-004 (Casual Link-Follower). Navigation must work without hover interactions. Connects to US-002 (breadcrumbs) for mobile wayfinding.
