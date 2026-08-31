---
id: US-082
title: "Empty search results with suggestions"
slug: empty-search-results-with-suggestions
personas: [P-007, P-001]
epic: "Edge Cases & Error States"
priority: should-have
complexity: low
tags: [error-state, search, ux]
---

# US-082: Empty Search Results With Suggestions

## User Story

**As a** novice occasional user
**I want to** see helpful refinement suggestions when my search returns nothing
**So that** I'm not stuck at a dead-end "no results" message with no idea what to try next

## Acceptance Criteria

- **Given** Jamie searches the plain search bar for a term with no matches
  **When** results return empty
  **Then** the UI shows "No results for '<query>'" plus suggestions in plain language: search by meaning instead of exact words, check spelling, broaden filters

- **Given** Marcus searches with a project filter applied and gets zero results
  **When** the empty state renders
  **Then** it specifically suggests removing or broadening the active project filter

- **Given** the "search by meaning" suggestion is shown
  **When** Jamie clicks it
  **Then** the same query re-runs in semantic search mode without retyping

## Notes
Jamie is wary of unfamiliar jargon, so the empty-state copy should avoid the term "semantic mode" in favor of a plain-language description ("search by meaning"), consistent with the persona's need for self-explanatory UI.
