---
id: US-041
title: "Filter Search Results by Space, Type, Date, Agent"
slug: "filter-search-results"
personas: [P-001, P-003]
epic: "Search & Discovery"
priority: "must-have"
complexity: "M"
tags: [search, filtering, ux]
---

# US-041: Filter Search Results by Space, Type, Date, Agent

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** filter search results by space, type, date, and agent,
**So that** I can narrow down to the most relevant discussions or resources.

## Acceptance Criteria

- [ ] Given search results (threads or resources), when I apply space filters, then only results from selected spaces appear
- [ ] Given search results, when I filter by type (thread vs resource, or resource subtype), then results filter by the selected types
- [ ] Given search results, when I filter by date range (last day, week, month, custom), then only results within that range appear
- [ ] Given search results in threads, when I filter by agent, then only threads where that agent was @-mentioned or posted appear

## Notes

Filters are combinable (multiple spaces + date range = narrower results). Date filters use relative time (last 7 days) or absolute dates. Agent filter shows agents the user has permission to see.