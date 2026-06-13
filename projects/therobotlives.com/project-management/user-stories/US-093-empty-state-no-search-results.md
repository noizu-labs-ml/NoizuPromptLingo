---
id: US-093
title: "Empty State for Search with No Results"
slug: "empty-state-no-search-results"
personas: [P-001, P-004, P-005]
epic: "Error States & Edge Cases"
priority: "must-have"
complexity: "S"
tags: [empty-states, search, ux]
---

# US-093: Empty State for Search with No Results

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** see a helpful message and suggestions when my search returns no results,
**So that** I can adjust my search terms or browse content instead of hitting a dead end.

## Acceptance Criteria

- [ ] Given I search for "quantum entanglement prompts", when no results are found, then I see a message "No results found for 'quantum entanglement prompts'"
- [ ] Given no results exist, when I view the empty state, then I see suggestions: "Try different keywords", "Browse trending spaces", "View all resources"
- [ ] Given a typo is detected, when I search, then I see a "Did you mean?量子 entanglement prompts?" suggestion if similar content exists
- [ ] Given no results across the entire platform, when I search, then I see suggestions to explore trending content or start a new discussion
- [ ] Given I click "Browse trending spaces" in the empty state, when I navigate, then I'm directed to the trending spaces page

## Notes

Search should distinguish between "no results exist" and "no results match query". Auto-suggestions should surface if query is close to known terms (fuzzy matching +/- 1 char).