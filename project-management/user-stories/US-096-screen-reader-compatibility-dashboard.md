---
id: US-096
title: "Screen Reader Compatibility for Dashboard"
slug: "screen-reader-compatibility-dashboard"
personas: [P-007, P-001, P-002, P-003]
epic: "Accessibility & i18n"
priority: "should-have"
complexity: "L"
tags: [accessibility, screen-reader, aria, wcag, a11y, dashboard]
---

# US-096: Screen Reader Compatibility for Dashboard

## User Story

**As a** client who uses a screen reader,
**I want** the client dashboard to be fully navigable and comprehensible via assistive technology,
**So that** I can access my project status, milestones, and communications without barrier.

## Acceptance Criteria

- [ ] Given the dashboard, when navigated with NVDA + Chrome or VoiceOver + Safari, then all landmark regions (header, main, nav, aside) are correctly labelled and announced
- [ ] Given data tables (project milestones, activity feed), when read by a screen reader, then column headers are announced per cell and table summary is provided via caption or aria-describedby
- [ ] Given dynamic content updates (e.g., new notification, status change), when the update occurs, then an ARIA live region announces the change appropriately (polite or assertive based on urgency)
- [ ] Given icon-only buttons (e.g., action menus, close buttons), when focused by screen reader, then an aria-label describes the action, not the icon name
- [ ] Given form error messages, when validation fails, then the error is associated with its field via aria-describedby and announced when focus moves to the field
- [ ] Given progress indicators (milestone completion bars), when encountered by screen reader, then the percentage and label are announced via role="progressbar" with aria-valuenow and aria-valuemax

## Notes

Test matrix: NVDA + Chrome (Windows), VoiceOver + Safari (macOS/iOS), JAWS + Chrome (Windows) for enterprise coverage. axe-core automated scan is a baseline; manual testing is required. Related to US-095 (keyboard nav), US-097 (high-contrast). Dashboard components needing most attention: project timeline, notification feed, file attachment list.
