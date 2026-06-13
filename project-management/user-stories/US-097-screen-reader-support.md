---
id: US-097
title: "Screen Reader Support"
slug: "screen-reader-support"
personas: [P-001, P-008]
epic: "Accessibility, Performance & Edge Cases"
priority: "could-have"
complexity: "M"
tags: [accessibility, screen-reader, aria, a11y, wcag]
---

# US-097: Screen Reader Support

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** use IoTGo with a screen reader such as NVDA, JAWS, or VoiceOver,
**So that** users with visual impairments can access the full functionality of the platform.

## Acceptance Criteria

- [ ] Given a page loads, when a screen reader announces the page, then the page title uniquely identifies the current section and the main landmark region contains the primary content
- [ ] Given a chart or graph is displayed, when a screen reader user navigates to it, then an accessible text alternative or data table describing the chart's key values is available
- [ ] Given a live telemetry feed updates, when new data arrives, then a polite ARIA live region announces the update without interrupting the user's current navigation context
- [ ] Given an error alert appears, when a screen reader user is on the page, then the alert is announced as an assertive live region within 1 second of appearing
- [ ] Given icon-only buttons are used, when a screen reader announces them, then each has an accessible name via aria-label or visually hidden text that describes the action

## Notes

Screen reader testing should be performed with NVDA + Firefox (Windows) and VoiceOver + Safari (macOS) before each release. Relates to US-096 (keyboard navigation). Complex visualizations may fall back to tabular data tables as their accessible equivalent.
