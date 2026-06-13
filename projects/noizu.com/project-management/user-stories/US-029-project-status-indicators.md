---
id: US-029
title: "Project Status Indicators (On-Track / At-Risk / Completed)"
slug: "project-status-indicators"
personas: [P-007, P-002, P-003, P-001]
epic: "Customer Dashboard"
priority: "must-have"
complexity: "S"
tags: [dashboard, status, indicators, ux]
---

# US-029: Project Status Indicators (On-Track / At-Risk / Completed)

## User Story

**As a** client monitoring project health (P-007),
**I want to** see clear visual status indicators on all project and milestone views,
**So that** I can instantly assess whether things are on track without reading detailed notes.

## Acceptance Criteria

- [ ] Given a project or milestone has status "on-track", when I view it in any dashboard context, then a green indicator (badge, icon, or color) is displayed
- [ ] Given a project or milestone has status "at-risk", when I view it, then an amber/yellow indicator is displayed with a brief reason tooltip
- [ ] Given a project or milestone has status "completed", when I view it, then a grey or checkmark indicator is shown
- [ ] Given a project or milestone has status "blocked", when I view it, then a red indicator is displayed
- [ ] Given I am using a screen reader, when I encounter a status indicator, then the status is conveyed via aria-label (not color alone)
- [ ] Given status changes, when the dashboard refreshes, then updated indicators reflect within the current session

## Notes

Status is set by Keith via admin. Must be WCAG 2.1 AA compliant — never rely on color alone. This design token system should be shared across dashboard, project detail (US-027), and milestone timeline views. Status vocabulary: on-track, at-risk, blocked, completed, on-hold.
