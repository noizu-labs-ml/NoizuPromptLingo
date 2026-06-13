---
id: US-038
title: "View deployment activity log with version history"
slug: "view-deployment-activity-log"
personas: [P-005, P-002]
epic: "JustMCP Deployment"
priority: "should-have"
complexity: "M"
tags: [justmcp, audit, activity-log, versioning]
---

# US-038: View Deployment Activity Log with Version History

## User Story

**As a** Engineering Manager (P-005),
**I want to** view a deployment activity log with version history for each MCP server,
**So that** I can track changes, understand who deployed what and when, and support incident investigation.

## Acceptance Criteria

- [ ] Given the user selects a deployed MCP server, when they navigate to the "Activity" tab, then the system displays a chronological activity log with each event showing timestamp, actor (user or system), action type, and summary.
- [ ] Given the activity log is displayed, when the user views version-change events, then each entry shows the from-version, to-version, trigger (manual deploy, rollback, auto-scale), and the diff summary of configuration changes.
- [ ] Given the activity log is displayed, when the user applies a filter, then they can filter by action type (deploy, scale, rollback, policy change, config change, deletion) and date range.
- [ ] Given the user clicks on a specific activity entry, when the detail panel opens, then it shows the full configuration snapshot at that point in time and the diff against the previous version.
- [ ] Given the user has appropriate permissions, when they click "Export activity log," then the system generates a downloadable JSON or CSV file of all activity entries for the selected date range.
- [ ] Given the activity log is long, when the user scrolls, then the system paginates or lazy-loads entries with a search bar for filtering by actor name, version tag, or action description.

## Notes

The activity log feeds from both the deployment system and the Audit Store. It provides the human-readable view complementing the machine-readable audit records. Related: US-029 (dashboard), US-034 (rollback).
