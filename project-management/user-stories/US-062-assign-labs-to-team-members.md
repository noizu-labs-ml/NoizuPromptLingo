---
id: US-062
title: "Assign Labs to Team Members"
slug: "assign-labs-to-team-members"
personas: [P-002, P-001]
epic: "Academy — Labs"
priority: "should-have"
complexity: "M"
tags: [academy, teams, assignments, enterprise, management]
---

# US-062: Assign Labs to Team Members

## User Story

**As an** enterprise AppSec manager (P-002),
**I want to** assign specific labs or learning paths to individual team members or the whole team,
**So that** I can run structured training programs with accountability and due dates.

## Acceptance Criteria

- [ ] Given I am a team admin or owner, when I navigate to the team's Assignments tab, then I can create a new assignment by selecting one or more labs or a full learning path, selecting assignees (individual members or "all"), and optionally setting a due date
- [ ] Given an assignment is created, when assigned members log in to Academy, then they see their pending assignments in a highlighted "Assigned to You" section with due date and assigning manager displayed
- [ ] Given a due date is set on an assignment, when the date approaches (configurable: default 3 days before), then assigned members receive an email reminder
- [ ] Given an assigned member completes an assigned lab, when the completion is recorded, then the assignment status updates to "Completed" in the team admin view with the completion timestamp
- [ ] Given I view the Assignments tab as a team admin, when I look at an assignment, then I see per-member completion status: not started / in progress / completed, with completion dates for finished members

## Notes

Assignments should not block members from doing other labs — they are a nudge and tracking mechanism, not a lock. Assignment notifications should be suppressible by members who prefer not to receive training reminders outside the platform.
