---
id: US-038
title: "Filter by Tag / Category"
slug: "filter-by-tag-category"
personas: [P-001, P-002, P-005, P-006, P-008]
epic: "Search & Discovery"
priority: "must-have"
complexity: "M"
tags: [filter, tags, categories, discovery]
---

# US-038: Filter by Tag / Category

## User Story

**As an** AI newcomer exploring the community (P-008),
**I want to** filter prompts by tag or category (e.g., "coding," "creative writing," "summarization"),
**So that** I can browse content relevant to my specific use case without wading through unrelated prompts.

## Acceptance Criteria

- [ ] Given I click on a tag displayed on a prompt card, when the click is registered, then the feed filters to show only prompts sharing that tag
- [ ] Given I am on the browse or search page, when I open the tag filter panel, then all available tags are listed with a count of associated prompts
- [ ] Given I apply multiple tag filters, when results are returned, then I can toggle between AND logic (all tags must match) and OR logic (any tag matches) via a toggle control
- [ ] Given a tag has fewer than 3 associated prompts, when the tag list renders, then it is still visible but marked as "sparse" with its count shown

## Notes

Tags and categories are hierarchical — categories are top-level groupings, tags are freeform within categories. Autocomplete should be provided when users type in the tag filter input. Tag filter state should be reflected in the URL query string to support sharing filtered views.
