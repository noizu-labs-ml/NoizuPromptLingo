---
id: US-002
title: "Category Breadcrumb Navigation"
slug: "category-breadcrumbs"
personas: [P-001, P-003, P-004]
epic: "Category Browsing"
priority: "must-have"
complexity: "S"
tags: [navigation, breadcrumbs, wayfinding, categories]
---

# US-002: Category Breadcrumb Navigation

## User Story

**As a** Casual Link-Follower (P-004),
**I want to** see a breadcrumb trail showing where I am in the category hierarchy,
**So that** I don't get lost and can easily backtrack to a parent category.

## Acceptance Criteria

- [ ] Given I am viewing a subcategory page, when the page loads, then a breadcrumb trail is displayed showing the full path from the root category to the current location.
- [ ] Given I see the breadcrumb trail, when I click any ancestor in the trail, then I am taken to that category's page.
- [ ] Given I am on a top-level category page, when the page loads, then only the category name appears (no parent breadcrumb).

## Notes

Breadcrumbs are critical for deep-linking (US-008) where users may land several levels deep via external links or search. Should be rendered as structured data (schema.org BreadcrumbList) for SEO.
