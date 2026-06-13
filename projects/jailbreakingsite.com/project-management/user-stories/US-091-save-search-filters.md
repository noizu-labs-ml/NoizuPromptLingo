---
id: US-091
title: "Save and Name Search Filters"
slug: "save-search-filters"
personas: [P-001, P-002, P-006]
epic: "Search & Discovery"
priority: "could-have"
complexity: "M"
tags: [search, filters, saved-searches, productivity, personalization]
---

# US-091: Save and Name Search Filters

## User Story

**As a** frequent catalog user with recurring research patterns (P-001, P-002, P-006),
**I want to** save named search filter combinations for queries I run regularly,
**So that** I can return to the same filtered view in one click rather than reconstructing the same filter state every session.

## Acceptance Criteria

- [ ] Given I have applied one or more search filters, when I click "Save Search", then I am prompted to name it and it is saved to my account
- [ ] Given saved searches, when I navigate to my profile or sidebar, then I see a list of all saved searches with name, filter summary, and last-run date
- [ ] Given a saved search, when I click it, then the search results page loads with that exact filter state applied
- [ ] Given a saved search, when I want to modify it, then I can update filters and save over the existing name or save as a new name
- [ ] Given a saved search, when I delete it, then it is removed from my list with an undo option available for 5 seconds
- [ ] Given saved searches, when results are available, then I can opt-in to receive a weekly digest email summarizing new content matching each saved search

## Notes

Saved searches are personal (not shared with org by default). Filter state to serialize includes: query string, content type, category, severity, model, date range, and sort order. Maximum of 20 saved searches on free tier, 100 on paid. Depends on US-090 for the search surface.
