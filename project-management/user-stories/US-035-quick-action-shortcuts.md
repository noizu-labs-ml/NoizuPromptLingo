---
id: US-035
title: "Quick-Action Shortcuts on Dashboard"
slug: "quick-action-shortcuts"
personas: [P-007, P-001, P-002]
epic: "Customer Dashboard"
priority: "could-have"
complexity: "S"
tags: [dashboard, quick-actions, ux, shortcuts]
---

# US-035: Quick-Action Shortcuts on Dashboard

## User Story

**As a** returning client who visits the dashboard regularly (P-007),
**I want to** access common actions (schedule a call, create a support ticket, download latest deliverable) from a quick-action panel on the dashboard,
**So that** I can complete frequent tasks in one click without navigating deep into project views.

## Acceptance Criteria

- [ ] Given I am on the main dashboard, when the page loads, then a quick-actions panel is visible showing 3–5 contextual shortcuts
- [ ] Given I have an active project with a recent deliverable, when I view quick actions, then "Download Latest Deliverable" is offered as a shortcut
- [ ] Given I have no upcoming meeting scheduled, when I view quick actions, then "Schedule a Call" is offered
- [ ] Given I click a quick-action shortcut, when it triggers, then I am taken directly to the relevant flow without extra navigation steps
- [ ] Given Keith configures a custom quick action for my account (e.g. "Review Draft Proposal"), when I log in, then it appears in my quick-actions panel

## Notes

Quick actions are context-sensitive — they should reflect the most relevant next step for the current engagement state. Start with a fixed set of 3–5 common actions before adding dynamic/admin-configurable ones. Related to US-026 (dashboard overview). This is a UX polish feature; core dashboard must be complete first.
