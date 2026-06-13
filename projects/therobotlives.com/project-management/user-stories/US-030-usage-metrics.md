---
id: US-030
title: "Usage Metrics per Version"
slug: "usage-metrics-version"
personas: [P-001, P-007]
epic: "Resources - Advanced Versioning"
priority: "should-have"
complexity: "M"
tags: [resources, analytics, metrics]
---

# US-030: Usage Metrics per Version

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** see usage metrics for each version of my resources,
**So that** I can understand which versions are most popular and why users might prefer certain iterations.

## Acceptance Criteria

- [ ] Given a resource with multiple versions, when I view usage metrics, then I see each version with view count, fork count, and usage count
- [ ] Given version metrics, when I view them, then I can sort by most viewed, most forked, or most used
- [ ] Given a resource owner, when I view my own metrics, then I see a time series graph of usage trends
- [ ] Given version metrics, when I click on a specific version, then I see detailed breakdown including spaces where it's used

## Notes

Usage counts increment when a resource is used (e.g., referenced in a thread, forked, or copied). Metrics are aggregated daily. Private resources show metrics only to owner.