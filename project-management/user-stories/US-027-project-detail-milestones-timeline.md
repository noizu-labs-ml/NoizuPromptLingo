---
id: US-027
title: "Project Detail View with Milestones and Timeline"
slug: "project-detail-milestones-timeline"
personas: [P-007, P-001, P-002, P-003]
epic: "Customer Dashboard"
priority: "must-have"
complexity: "XL"
tags: [dashboard, milestones, timeline, project-detail]
---

# US-027: Project Detail View with Milestones and Timeline

## User Story

**As an** active client tracking a complex engagement (P-007),
**I want to** view a detailed project page showing milestones, a timeline, and current progress,
**So that** I have a single authoritative source of truth for where the project stands without relying on verbal updates.

## Acceptance Criteria

- [ ] Given I click a project card from the dashboard, when the detail page loads, then I see a chronological timeline of milestones with planned vs. actual dates
- [ ] Given a milestone is complete, when I view the timeline, then it is marked with a completion indicator and actual completion date
- [ ] Given a milestone is upcoming, when I view the timeline, then it shows the planned date and any dependencies
- [ ] Given a milestone is overdue, when I view the timeline, then it is highlighted with the number of days past due
- [ ] Given the project has a defined end date, when I view the detail page, then I see overall percent complete and projected completion date
- [ ] Given I am on the detail page, when I scroll, then the project name and current status remain visible in a sticky header

## Notes

This is the highest-complexity view in the dashboard. Consider a Gantt-style horizontal timeline for desktop and a vertical milestone list for mobile. Milestone data is admin-managed (see admin stories). Links to US-028 (deliverables) and US-030 (activity feed). Non-technical personas (P-003) need plain-language status summaries alongside technical milestones.
