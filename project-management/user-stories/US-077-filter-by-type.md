---
id: US-077
title: "Filter mockups by type"
slug: "filter-by-type"
personas: [P-003, P-001, P-005]
epic: "Search & Discovery"
priority: "should-have"
complexity: "S"
tags: [search, filter, discovery]
---

# US-077: Filter mockups by type

## User Story

**As a** UX Designer (P-003),
**I want to** filter my mockup library by type (wireframe, diagram, architecture),
**So that** I can focus on the category of artifacts relevant to my current task.

## Acceptance Criteria

- [ ] Given I am viewing the mockup gallery, when I select a type filter (wireframe, diagram, architecture), then only mockups of that type are displayed
- [ ] Given a type filter is active, when I clear the filter, then all mockup types are displayed again
- [ ] Given multiple type filters are selected, when results are shown, then mockups matching any selected type are included

## Notes

Type values are determined at generation time based on the tool used (PlantUML, Mermaid, image AI, SVG). Can be combined with date range (US-078) and tag filters (US-079).
