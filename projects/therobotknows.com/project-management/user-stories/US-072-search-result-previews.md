---
id: US-072
title: "Search Result Previews"
slug: "search-result-previews"
personas: [P-001, P-002, P-005, P-008]
epic: "Search & Discovery"
priority: "should-have"
complexity: "S"
tags: [search, preview, ux, results, snippet]
---

# US-072: Search Result Previews

## User Story

**As a** hobbyist worldbuilder (P-005),
**I want to** see a rich preview of each search result without opening the full entry,
**So that** I can quickly scan results and identify the right entry before committing to a navigation click.

## Acceptance Criteria

- [ ] Given search results are displayed, when I hover over (desktop) or long-press (mobile) a result card, then a preview panel appears showing the entry's name, type, tags, first 300 characters of body text, and last-edited timestamp.
- [ ] Given the preview panel is visible, when the matching keyword appears in the preview body text, then the keyword is highlighted in the preview with the same highlight color used in full search result snippets.
- [ ] Given a search result represents an entry with a cover image or icon, when the preview appears, then the image or icon is displayed in the preview panel alongside the text.
- [ ] Given I click anywhere on a result card (not just the preview trigger), when the click registers, then I navigate to the full entry detail view, and the preview dismisses.

## Notes

Previews reduce navigation overhead for power users scanning large result sets. Depends on US-069 (full-text search), US-071 (filters). Preview content must respect entry visibility settings — GM-only sections omitted if viewer lacks permission.
