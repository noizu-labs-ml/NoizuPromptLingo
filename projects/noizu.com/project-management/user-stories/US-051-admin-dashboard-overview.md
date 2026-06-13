---
id: US-051
title: "Admin Dashboard Overview"
slug: "admin-dashboard-overview"
personas: [P-007]
epic: "Admin Dashboard"
priority: "must-have"
complexity: "L"
tags: [admin, dashboard, overview, clients, projects]
---

# US-051: Admin Dashboard Overview

## User Story

**As a** site administrator (Keith / P-007 proxy),
**I want to** see a unified overview of all clients, active projects, pending inquiries, and recent activity on a single dashboard screen,
**So that** I can quickly assess the health of my consulting business without navigating across multiple pages.

## Acceptance Criteria

- [ ] Given I am authenticated as an admin, when I navigate to `/admin`, then I see a dashboard with summary cards: active clients, open projects, pending inquiries, and unread messages.
- [ ] Given the dashboard loads, when data is present, then each summary card displays a count and a trend indicator (up/down vs. prior 30 days).
- [ ] Given the dashboard loads, when I click a summary card, then I am taken to the corresponding list view filtered to that status.
- [ ] Given the dashboard loads, when there are recent admin actions in the last 24 hours, then a "Recent Activity" feed shows the last 10 entries with actor, action, and timestamp.
- [ ] Given I am on the dashboard, when I have not completed onboarding configuration, then a setup checklist widget is displayed at the top.

## Notes

This is the admin entry point. All other admin epics (US-052 through US-065) surface data here. Keep the layout scan-friendly for solo-operator use — Keith is the only admin initially. Related: US-052 (client management), US-056 (inquiry triage), US-063 (audit log).
