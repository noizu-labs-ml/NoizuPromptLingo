---
id: US-029
title: "View Fork Graph and Lineage"
slug: "fork-graph"
personas: [P-001, P-006]
epic: "Resources - Advanced Versioning"
priority: "should-have"
complexity: "L"
tags: [resources, forking, visualization]
---

# US-029: View Fork Graph and Lineage

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** visualize the fork graph and lineage of a resource,
**So that** I can understand how a resource has been adapted and evolved by the community.

## Acceptance Criteria

- [ ] Given a resource with forks, when I view the fork graph, then I see a tree visualization showing the original and all direct forks
- [ ] Given a resource, when I view its lineage, then I can traverse up to the original source and down to all descendant forks
- [ ] Given a fork in the graph, when I click on a node, then I see metadata like owner, version count, and last updated timestamp
- [ ] Given a fork graph, when I view it, then inactive forks (no updates in 30 days) are visually distinguished from active ones

## Notes

Fork graph limits display to 50 nodes (show loading for larger trees). Private forks require login to view. Lineage depth should be capped to prevent rendering issues.