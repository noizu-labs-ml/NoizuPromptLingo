---
id: US-090
title: "Empty State for New Client Dashboard"
slug: "empty-state-new-client"
personas: [P-007, P-001, P-002, P-003]
epic: "Edge Cases & Error States"
priority: "must-have"
complexity: "S"
tags: [dashboard, empty-state, onboarding, ux]
---

# US-090: Empty State for New Client Dashboard

## User Story

**As a** newly onboarded client with no active projects yet (P-007),
**I want to** see a helpful empty state when I first access my dashboard,
**So that** I understand what the portal is for and know how to take the next step rather than facing a blank screen.

## Acceptance Criteria

- [ ] Given an authenticated user whose account has no associated projects or RFIs, when the dashboard loads, then an empty state illustration and explanatory copy are shown instead of empty lists
- [ ] Given the empty state, then it includes a clear call to action: "Submit a Request for Information" with a link to the RFI form
- [ ] Given the empty state, then it shows a brief explanation of what will appear here once an engagement begins (projects, milestones, updates)
- [ ] Given the empty state, when a project is later created for the user, then the next dashboard load shows the project list instead of the empty state
- [ ] Given the empty state, then the header navigation and support contact link remain fully functional

## Notes

Do not show empty list containers (e.g., "Projects (0)" with nothing below). Each section should either have content or a contextual empty state message. Illustration should be on-brand and not generic. Related to US-026 (dashboard overview), US-089 (404). Consider a "getting started" checklist variant for onboarding.
