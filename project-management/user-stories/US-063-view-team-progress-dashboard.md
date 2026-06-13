---
id: US-063
title: "View Team Progress Dashboard"
slug: "view-team-progress-dashboard"
personas: [P-002, P-005]
epic: "Academy — Labs"
priority: "should-have"
complexity: "L"
tags: [academy, teams, dashboard, reporting, enterprise]
---

# US-063: View Team Progress Dashboard

## User Story

**As an** enterprise AppSec manager (P-002),
**I want to** view a team progress dashboard showing aggregate and per-member training activity,
**So that** I can report on training completion to leadership and identify team members who need support.

## Acceptance Criteria

- [ ] Given I am a team admin or owner, when I navigate to the team dashboard, then I see aggregate metrics: total labs completed by the team, average score, completion rate for assigned labs, and active members this month
- [ ] Given the team dashboard is loaded, when I view the member table, then I see per-member stats: labs completed, assigned labs completion rate, last active date, and earned credentials count
- [ ] Given I click on a member row, when the member detail panel opens, then I see that member's full Academy progress including lab history, scores, and learning path status
- [ ] Given I want a report for leadership, when I click "Export Report," then I can download a CSV or PDF summary of team training activity for a selectable date range
- [ ] Given the team has active assignments, when I view the dashboard, then an "Assignments Overview" section shows each assignment's due date, completion rate, and overdue count

## Notes

The member detail view in the team dashboard should respect member privacy settings — if a member has set their profile to private, the team admin still sees their completion data (as it relates to assigned work) but cannot see their full personal lab history. This requires careful permission scoping.
