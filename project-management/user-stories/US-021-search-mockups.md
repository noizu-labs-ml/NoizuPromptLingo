---
id: US-021
title: "Search mockups by name, tag, or generation prompt"
slug: "search-mockups"
personas: [P-001, P-002, P-003]
epic: "Mockup Management"
priority: "should-have"
complexity: "M"
tags: [mockup-management, search, tags, filtering]
---

# US-021: Search mockups by name, tag, or generation prompt

## User Story

**As a** full-stack developer (P-001),
**I want to** search my mockup library by keyword, tag, or prompt text,
**So that** I can locate a specific mockup quickly when the gallery has grown large.

## Acceptance Criteria

- [ ] Given I type in the search bar, when at least 2 characters are entered, then results update in real time (debounced 300ms) matching mockup names and generation prompts
- [ ] Given a search query, when results are displayed, then matching text is highlighted in the mockup name and prompt excerpt on each result card
- [ ] Given I add a tag to a mockup, when I search for that tag with a `tag:` prefix (e.g., `tag:auth-flow`), then only mockups with that exact tag are returned
- [ ] Given a search returns no results, when the empty state is shown, then I see the query echoed back with suggestions to broaden the search or clear filters

## Notes

Full-text search indexes: mockup name, original prompt, tags, project name. Search is scoped to the current user's mockups only. Tags are added via the mockup detail view; a tag normalization step lowercases and strips whitespace. Related to US-019, US-020.
