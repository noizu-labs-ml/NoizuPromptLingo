---
id: US-028
title: "Search-as-you-type live results"
slug: search-as-you-type-live-results
personas: [P-001]
epic: "Search & Discovery"
priority: could-have
complexity: medium
tags: [search, performance, ux]
---

# US-028: Search-As-You-Type Live Results

## User Story

**As a** solo power-user developer
**I want to** see results update live as I type in the search bar, without pressing enter
**So that** I get faster feedback loops when hunting for a half-remembered term across my client repos

## Acceptance Criteria

- **Given** I start typing a query in the search bar
  **When** I pause typing for a short debounce window (e.g. 250-300ms)
  **Then** results refresh automatically without requiring an explicit submit action

- **Given** I am typing quickly across many keystrokes
  **When** each keystroke fires
  **Then** in-flight prior requests are cancelled/superseded so only the latest query's results render (no out-of-order flicker)

- **Given** the corpus is large (thousands of indexed messages across many projects)
  **When** live search is active
  **Then** the UI remains responsive — no typing lag — because queries are debounced and results are paginated/limited rather than fetching the full result set on every keystroke

## Notes
Could-have — this is a UX refinement over the existing submit-based search (US-021/US-022) rather than new core capability, deferred until the base search paths are solid. Marcus is the primary beneficiary given how much of his workflow is rapid CLI/web search iteration.
