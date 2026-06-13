---
id: US-026
title: "Dashboard Overview with Active Projects"
slug: "dashboard-overview-active-projects"
personas: [P-007, P-001, P-002]
epic: "Customer Dashboard"
priority: "must-have"
complexity: "L"
tags: [dashboard, projects, overview, authenticated]
---

# US-026: Dashboard Overview with Active Projects

## User Story

**As an** active client with ongoing engagements (P-007),
**I want to** see a summary dashboard of all my active projects when I log in,
**So that** I can quickly orient to current status across all engagements without hunting through emails or status threads.

## Acceptance Criteria

- [ ] Given I am authenticated, when I navigate to `/dashboard`, then I see a grid or list of all my active project cards
- [ ] Given I have multiple active projects, when the dashboard loads, then each card shows project name, engagement type, current status indicator, and last-updated timestamp
- [ ] Given a project is at-risk or overdue, when I view the dashboard, then that card is visually differentiated (e.g. amber/red border or badge)
- [ ] Given I have no active projects, when I log in, then I see an empty state with a CTA to initiate a new engagement
- [ ] Given I am on mobile, when I load the dashboard, then the layout adapts to a single-column card stack without data loss

## Notes

Entry point for all authenticated client interactions. Should load in under 2s. Project cards link to US-027 (project detail view). Status indicators share the same taxonomy as US-029. Consider a "last login" banner for returning users who may have missed updates.
