---
id: US-046
title: "Moderator Dashboard with Queue Stats"
slug: "moderator-dashboard"
personas: [P-005]
epic: "Moderation & Review"
priority: "must-have"
complexity: "L"
tags: [moderation, dashboard, metrics, operations]
---

# US-046: Moderator Dashboard with Queue Stats

## User Story

**As a** content moderator (P-005),
**I want to** view an at-a-glance dashboard of the review queue's health and my recent activity,
**So that** I can efficiently manage my workload and spot bottlenecks before they become backlogs.

## Acceptance Criteria

- [ ] Given I log in as a moderator, when I navigate to the moderator dashboard, then I see: total items in queue, items older than 72 hours, my decisions in the last 7 days, team-wide approval/rejection ratio, and average time-to-decision
- [ ] Given the dashboard is loaded, when I click any stat card, then I am taken to a filtered view of the queue showing only the items matching that stat category
- [ ] Given a queue item has been waiting more than 7 days, when I view the dashboard, then it is highlighted in a red "overdue" section at the top of the queue list
- [ ] Given I am the only active moderator, when queue depth exceeds 50 items, then I receive an alert email prompting escalation or assistance

## Notes

Dashboard also surfaces the community flag review sub-queue (US-047) and appeal queue (US-048) as separate sections. Metrics feed into the score recalibration workflow (US-050) by surfacing patterns in borderline decisions.
