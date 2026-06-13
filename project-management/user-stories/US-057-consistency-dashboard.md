---
id: US-057
title: "Consistency Dashboard"
slug: "consistency-dashboard"
personas: [P-001, P-002, P-003, P-004, P-005]
epic: "Consistency Engine"
priority: "must-have"
complexity: "L"
tags: [consistency, dashboard, overview, triage]
---

# US-057: Consistency Dashboard

## User Story

**As a** fiction podcaster (P-004),
**I want to** see all outstanding consistency issues for my universe in one dashboard,
**So that** I have a single place to triage, resolve, and track the health of my 50-episode horror canon.

## Acceptance Criteria

- [ ] Given a universe has consistency issues, when I navigate to the Consistency Dashboard, then I see a summary panel with total open issues broken down by severity, and a sortable/filterable issue list below it.
- [ ] Given the issue list, when I sort by severity descending, then errors appear first, then warnings, then suggestions, with each group sorted by most recently detected.
- [ ] Given I filter by entry type (e.g., "characters only"), when the filter is applied, then only issues where at least one involved entry is of the selected type are shown.
- [ ] Given a universe with no open consistency issues, when I load the Consistency Dashboard, then I see a "No issues found" state with a green health indicator and the timestamp of the last completed check.
- [ ] Given the dashboard is open, when a new issue is detected in real time (per US-060), then the issue list updates without a full page reload and the summary counts increment.

## Notes

The Consistency Dashboard is the entry point for the entire Consistency Engine feature set. All other consistency stories (US-051 through US-060) surface their output here. Related: US-058 (batch check), US-059 (audit log).
