---
id: US-038
title: "Multi-Project Comparison View"
slug: "multi-project-comparison"
personas: [P-002, P-006]
epic: "Customer Dashboard"
priority: "won't-have-yet"
complexity: "XL"
tags: [dashboard, comparison, multi-project, advanced]
---

# US-038: Multi-Project Comparison View

## User Story

**As an** Engineering VP or enterprise procurement manager overseeing multiple concurrent engagements (P-002, P-006),
**I want to** view a side-by-side or aggregated comparison of multiple projects' health, timeline, and budget,
**So that** I can report to leadership and make resource decisions across engagements without manually aggregating data from each project view.

## Acceptance Criteria

- [ ] Given I have 2 or more active projects, when I enter comparison mode, then I can select up to 4 projects to compare
- [ ] Given I select projects for comparison, when the comparison view renders, then I see a table with rows for: status, percent complete, days to deadline, open blockers, and invoice balance
- [ ] Given I want to export the comparison, when I click "Export", then a PDF or CSV is generated with the comparison data
- [ ] Given I am in comparison mode, when I click a project cell, then I navigate to the full project detail for that project
- [ ] Given the comparison table has more columns than fit on screen, when I scroll horizontally, then the project name column remains sticky

## Notes

Deferred — requires all individual project views to be stable first. Most relevant for clients with retainer arrangements covering multiple simultaneous workstreams. A simpler v1 might just be the dashboard overview (US-026) with sortable/filterable columns rather than a dedicated comparison view. Revisit after 3+ clients are using the dashboard.
