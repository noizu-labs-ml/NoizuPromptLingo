---
id: US-097
title: "Screen reader user accesses all dashboard content with proper ARIA labels"
slug: "screen-reader-accessibility"
personas: [P-001, P-007]
epic: "Accessibility & i18n"
priority: "should-have"
complexity: "L"
tags: [accessibility, screen-reader, aria, wcag, a11y]
---

# US-097: Screen Reader User Accesses All Dashboard Content with Proper ARIA Labels

## User Story

**As a** Solo AI Hobbyist (P-007),
**I want to** access all dashboard content, metrics, and interactive elements using a screen reader with proper ARIA semantics,
**So that** I can fully understand and interact with the platform regardless of visual ability.

## Acceptance Criteria

- [ ] Given a screen reader user navigates the dashboard, when they encounter charts and graphs, then each data visualization has an associated aria-label or aria-describedby element that provides a text summary of the data (e.g., "Invocation chart: 1,200 requests in last 24 hours, peak at 2:00 PM with 85 requests")
- [ ] Given a screen reader user navigates a data table (e.g., server list, audit log), when they move through table cells, then the table uses proper th elements with scope attributes and the screen reader announces column headers when entering new cells
- [ ] Given a screen reader user encounters a loading state or dynamically updated content, when the content changes (e.g., invocation count updates, new log entries), then an aria-live region announces the update without interrupting the user's current focus
- [ ] Given a screen reader user interacts with custom UI components (toggles, dropdowns, modals), when they navigate to each component, then the component has the correct ARIA role (switch, listbox, dialog), state attributes (aria-expanded, aria-checked), and label

## Notes

Target WCAG 2.1 Level AA. Test with VoiceOver (macOS), NVDA (Windows), and JAWS. All images must have alt text, all form inputs must have associated labels, and all interactive elements must have accessible names. The audit log and analytics dashboard are the most complex surfaces for screen reader accessibility and should receive priority testing.
