---
id: US-025
title: "Filter search results by date range"
slug: filter-search-by-date-range
personas: [P-001, P-005]
epic: "Search & Discovery"
priority: should-have
complexity: low
tags: [search, filter]
---

# US-025: Filter Search Results by Date Range

## User Story

**As an** engineering lead auditing team AI usage
**I want to** scope search results to a recent date range like "last 7 days"
**So that** my weekly oversight scan only surfaces conversations from the current review window instead of the entire historical corpus

## Acceptance Criteria

- **Given** search results span several months of conversation history
  **When** I apply a "last 7 days" date-range filter
  **Then** only results from messages timestamped within the last 7 days remain

- **Given** I set a custom start and end date
  **When** I apply the filter
  **Then** results are scoped to that exact inclusive range

- **Given** a date-range filter is combined with a project filter
  **When** both are active
  **Then** results satisfy both constraints simultaneously (same project AND within range)

## Notes
Daniel's weekly audit workflow depends on quickly bounding results to "this week" before spot-checking for leaked secrets or odd threads; Marcus uses it to recall "something from last Tuesday." Low complexity — filters on an existing indexed timestamp field.
