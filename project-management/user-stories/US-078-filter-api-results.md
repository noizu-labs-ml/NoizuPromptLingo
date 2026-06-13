---
id: US-078
title: "Filter API Results by Model, Severity, and Category"
slug: "filter-api-results"
personas: [P-001, P-003, P-007]
epic: "API & Integration"
priority: "should-have"
complexity: "M"
tags: [api, filtering, catalog, developer, search]
---

# US-078: Filter API Results by Model, Severity, and Category

## User Story

**As a** developer building targeted threat intelligence pipelines (P-001, P-003, P-007),
**I want to** filter catalog API results by model family, severity level, and technique category,
**So that** I only retrieve the subset of techniques relevant to my specific LLM stack and risk posture.

## Acceptance Criteria

- [ ] Given the `/v1/techniques` endpoint, when I pass `?model=gpt-4` as a query param, then only techniques with `gpt-4` in their model targets are returned
- [ ] Given the `/v1/techniques` endpoint, when I pass `?severity=critical,high`, then only techniques with those severity ratings are returned
- [ ] Given the `/v1/techniques` endpoint, when I pass `?category=prompt-injection`, then only techniques in that category are returned
- [ ] Given multiple filters, when I combine `?model=claude&severity=high&category=context-manipulation`, then results satisfy all filter conditions (AND semantics)
- [ ] Given an invalid filter value, when I pass `?severity=invalid`, then a 400 is returned with a descriptive error listing valid values
- [ ] Given the response, when filters are active, then the response envelope includes a `filters_applied` object echoing the active parameters for debugging

## Notes

Filter parameter names must match the field names in the technique schema to reduce integration friction. Multi-value params support comma-separated or repeated key syntax (`?severity=high&severity=critical`). Depends on US-077 being complete.
