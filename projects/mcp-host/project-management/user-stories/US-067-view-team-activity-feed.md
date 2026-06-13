---
id: US-067
title: "View team activity feed showing recent deployments and policy changes"
slug: "view-team-activity-feed"
personas: [P-005, P-002]
epic: "Organization Management"
priority: "could-have"
complexity: "M"
tags: [organization, activity-feed, audit, observability]
---

# US-067: View Team Activity Feed Showing Recent Deployments and Policy Changes

## User Story

**As a** Engineering Manager (P-005),
**I want to** view an activity feed showing recent team actions including deployments, policy changes, and configuration updates,
**So that** I have visibility into what is happening across the organization without needing to check individual servers or ask team members.

## Acceptance Criteria

- [ ] Given the user is a member of an organization, when they navigate to the org activity feed page, then the system displays a reverse-chronological list of recent actions taken by any org member.
- [ ] Given the activity feed loads, when events are displayed, then each event includes: the action type (deployment, policy change, key rotation, role change, server update), the actor (team member name and avatar), the affected resource (server name or org setting), and the timestamp.
- [ ] Given the user wants to narrow the feed, when they apply filters, then they can filter by action type, actor, date range, and affected server.
- [ ] Given a deployment event is shown in the feed, when the user clicks on it, then they are navigated to the deployment detail showing the version, configuration changes, and current status (US-029).
- [ ] Given a policy change event is shown, when the user clicks on it, then a diff view opens showing the previous and updated policy with additions and deletions highlighted.
- [ ] Given the activity feed is long, when the user scrolls, then older events load via infinite scroll with a minimum retention of 90 days of history.

## Notes

The activity feed is a lightweight audit view distinct from the full SafeMCP audit log. It focuses on team-readable summaries rather than compliance-grade records. Related: US-061, US-062, US-064, US-066.
