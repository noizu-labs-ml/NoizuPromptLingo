---
id: US-031
title: "Cross-project dependency tracking"
personas: [james-oduya, lin-zhao]
domain: projects
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **James Oduya (Agency Owner)** or **Lin Zhao (Platform Engineer)**, I want to track dependencies between items across different projects so that I can identify and manage cross-project blockers before they cascade.

## Acceptance Criteria

- [ ] Items in any project can declare a dependency on items in other projects within the same workspace, using the same "blocks/blocked-by" semantics as intra-project dependencies
- [ ] A cross-project dependency view visualizes inter-project links as a graph, highlighting blocked chains and critical paths that span multiple projects
- [ ] When a blocking item's status changes (completed, delayed, or re-scoped), all dependent items' owners receive a notification with context about the impact
- [ ] The portfolio dashboard (US-025) incorporates cross-project dependency risk into its health indicators — a project blocked by another project's delayed item shows elevated risk
- [ ] Dependency creation requires confirmation from the target project's owner or lead to prevent unilateral cross-project coupling

## Notes

Cross-project dependencies are where complexity explodes. The UI must make these visible without overwhelming — consider a "dependency radar" that shows only the dependencies relevant to the current user's projects. For Lin's governance use case, audit trails on dependency creation and resolution are essential. Guard against circular dependency chains with validation at creation time.
