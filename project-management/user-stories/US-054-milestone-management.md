---
id: US-054
title: "Milestone Management"
slug: "milestone-management"
personas: [P-007]
epic: "Admin Dashboard"
priority: "must-have"
complexity: "M"
tags: [admin, milestone, project, timeline, progress]
---

# US-054: Milestone Management

## User Story

**As a** site administrator,
**I want to** create, update, and complete milestones within a project,
**So that** clients can see structured progress and I can track delivery commitments.

## Acceptance Criteria

- [ ] Given I am on a project detail page, when I click "Add Milestone", then a form appears with fields: title, description, due date, and associated deliverables (optional).
- [ ] Given a milestone exists, when I click "Mark Complete", then the milestone status changes to Complete, a completion date is recorded, and the client dashboard reflects the update.
- [ ] Given a milestone, when I edit its due date, then the change is saved and an audit entry is logged.
- [ ] Given a project with multiple milestones, when I view the project detail, then milestones are displayed in chronological order with status badges (Pending, In Progress, Complete, Overdue).
- [ ] Given a milestone due date has passed and status is not Complete, then it is automatically flagged as Overdue and highlighted in the admin project view.
- [ ] Given I delete a milestone, when I confirm the prompt, then it is removed and any linked deliverables are unlinked (not deleted).

## Notes

Milestones are visible to clients on their dashboard (US-???). Overdue detection should run server-side on page load and optionally on a nightly job. Related: US-053, US-055.
