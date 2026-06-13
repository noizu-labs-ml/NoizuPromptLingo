---
id: US-100
title: "Empty States & First-Run Experience"
slug: "empty-states-first-run-experience"
personas: [P-001, P-008]
epic: "Accessibility, Performance & Edge Cases"
priority: "must-have"
complexity: "S"
tags: [onboarding, empty-state, first-run, ux]
---

# US-100: Empty States & First-Run Experience

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** see helpful empty states with clear next-step guidance on every page that has no data yet,
**So that** I can quickly understand what needs to be configured and get value from IoTGo without consulting documentation.

## Acceptance Criteria

- [ ] Given I have just created an account and no sources are connected, when I visit the main dashboard, then an empty state illustration is displayed with the message "Connect your first device source to get started" and a prominent "Add Source" button
- [ ] Given a fleet group has no agents assigned, when I view that fleet group's agent list, then the empty state reads "No agents deployed to this fleet" with an "Add Agent" call-to-action
- [ ] Given a report view has no data for the selected time range, when the page renders, then the empty state distinguishes between "No data available yet" (new account) and "No events in selected period" (date range issue) with appropriate guidance for each
- [ ] Given filters are applied that return zero results, when the list renders empty, then the empty state shows "No results match your filters" with a "Clear Filters" button rather than the default no-data message
- [ ] Given I complete the onboarding wizard (US-002), when I land on the dashboard for the first time with data flowing, then a dismissible "You're set up!" success banner with a link to the Getting Started guide is shown

## Notes

Empty states should use consistent illustration style from the design system. Each major section (Sources, Agents, Fleet Groups, Reports, Incidents) must have its own contextually appropriate empty state copy. Relates to US-002 (onboarding wizard) and US-098 (loading states).
