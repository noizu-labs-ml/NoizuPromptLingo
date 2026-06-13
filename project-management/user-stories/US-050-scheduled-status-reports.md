---
id: US-050
title: "Scheduled Status Reports"
slug: "scheduled-status-reports"
personas: [P-007, P-002, P-003, P-006]
epic: "Support & Communication"
priority: "won't-have-yet"
complexity: "L"
tags: [reporting, status, automation, communication]
---

# US-050: Scheduled Status Reports

## User Story

**As a** client who needs to brief stakeholders on engagement progress (P-002, P-003),
**I want to** receive automatically generated status reports on a scheduled cadence (weekly, bi-weekly),
**So that** I can share project health summaries with my leadership team without manually compiling data from the dashboard.

## Acceptance Criteria

- [ ] Given I configure a status report schedule, when I set frequency (weekly/bi-weekly/monthly) and delivery day, then reports are generated and emailed on that schedule
- [ ] Given a scheduled report is generated, when I receive it, then it contains: project status summary, milestones completed since last report, upcoming milestones, open support tickets, and any blockers
- [ ] Given I want to customize what the report includes, when I edit report settings, then I can toggle individual sections on or off
- [ ] Given I want an on-demand report, when I click "Generate Now", then a report is created immediately and I receive it within 5 minutes
- [ ] Given the report is generated, when I view it, then it is formatted as a clean HTML email and is also downloadable as a PDF

## Notes

Deferred — requires the full dashboard data model (milestones, deliverables, tickets) to be stable and populated before reports are meaningful. Report generation should be idempotent and retryable. Template-driven with Keith branding. Consider client-configurable report recipients (e.g. add a stakeholder email) in a later version. This is the highest-complexity communication feature and should only be built once simpler async communication flows are proven and in use.
