---
id: US-023
title: "Filter search results by project"
slug: filter-search-by-project
personas: [P-001, P-005]
epic: "Search & Discovery"
priority: must-have
complexity: low
tags: [search, filter]
---

# US-023: Filter Search Results by Project

## User Story

**As a** solo power-user developer
**I want to** narrow search results to one or more specific projects
**So that** I can find a match within a particular client repo without wading through results from my other 3-5 client codebases

## Acceptance Criteria

- **Given** I have run a keyword or semantic search that returns results across multiple projects
  **When** I select one project from a project filter control
  **Then** the result list updates to show only matches from that project, without re-submitting the search query text

- **Given** I have selected two or more projects in the filter
  **When** results render
  **Then** matches from any of the selected projects are shown, combined and still ranked by relevance/similarity

- **Given** I clear the project filter
  **When** the filter resets
  **Then** the full unfiltered result set for my last query reappears

## Notes
Daniel uses this during his weekly oversight scan to scope a search to a specific team project before spot-checking threads; Marcus uses it to isolate one client's repo. Low complexity — this is a client-side/query-param narrowing of an already-executed search, not a new search pipeline.
