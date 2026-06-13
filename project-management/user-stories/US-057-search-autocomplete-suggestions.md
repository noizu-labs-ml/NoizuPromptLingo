---
id: US-057
title: "Search Autocomplete and Suggestions"
slug: "search-autocomplete-suggestions"
personas: [P-004, P-001, P-003]
epic: "Search & Filtering"
priority: "should-have"
complexity: "M"
tags: [search, autocomplete, suggestions, ux, typeahead]
---

# US-057: Search Autocomplete and Suggestions

## User Story

**As a** casual link-follower (P-004),
**I want to** see autocomplete suggestions as I type in the search bar,
**So that** I can find relevant results faster and discover topics I did not know to look for.

## Acceptance Criteria

- [ ] Given I begin typing in the search bar, when I have entered 2 or more characters, then a dropdown shows up to 8 autocomplete suggestions
- [ ] Given the autocomplete dropdown is visible, when suggestions appear, then they include a mix of: matching category names, matching tags, and popular recent searches
- [ ] Given a suggestion in the dropdown, when I click or keyboard-navigate to it, then the search executes immediately with that term
- [ ] Given the search bar is focused and autocomplete fires, when my input exactly matches a category name, then a "Browse [Category]" shortcut is shown at the top of suggestions
- [ ] Given a slow network connection, when autocomplete suggestions are loading, then a subtle loading indicator is shown in the dropdown rather than a blank or stale list

## Notes

Suggestions should be derived from indexed tags and category names — not user query history or external autocomplete APIs — to keep suggestions aligned with actual directory content. Related: US-051 (keyword search), US-058 (empty state).
