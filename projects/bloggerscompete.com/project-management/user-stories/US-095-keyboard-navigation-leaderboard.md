---
id: US-095
title: "Keyboard Navigation for Leaderboard"
slug: "keyboard-navigation-leaderboard"
personas: [P-006, P-001]
epic: "Accessibility & i18n"
priority: "should-have"
complexity: "M"
tags: [accessibility, keyboard-navigation, leaderboard, WCAG, a11y]
---

# US-095: Keyboard Navigation for Leaderboard

## User Story

**As a** blog reader who relies on keyboard navigation (P-006),
**I want to** browse and interact with the competition leaderboard entirely using my keyboard,
**So that** I can access all leaderboard features without needing a mouse or touch input.

## Acceptance Criteria

- [ ] Given I am on the leaderboard page, when I press Tab, then focus moves sequentially through all interactive elements (filter controls, leaderboard rows, pagination) in a logical document order.
- [ ] Given focus is on a leaderboard row, when I press Enter or Space, then the blog detail panel or link activates as if I had clicked it.
- [ ] Given I am navigating filter controls (category dropdown, time period), when I use Arrow keys within the dropdown, then options are navigated with Up/Down arrows and selected with Enter.
- [ ] Given any interactive element receives focus, when it is focused, then a visible focus ring (minimum 3px outline, meeting WCAG 2.1 AA §2.4.7) is displayed around the element.
- [ ] Given I press Escape while a modal or dropdown is open, when Escape is pressed, then the modal/dropdown closes and focus returns to the element that triggered it.
- [ ] Given the leaderboard table, when rendered, then it uses proper `<table>`, `<th scope="col">`, and `<th scope="row">` markup so screen readers and keyboard users can navigate by column/row.
- [ ] Given keyboard navigation is used throughout the leaderboard, when tested with axe-core or similar automated tool, then zero critical or serious accessibility violations are reported.

## Notes

Keyboard nav and screen reader support are complementary — this story focuses on keyboard interaction; US-096 covers screen reader specifics. Leaderboard rows that are anchor tags (`<a href>`) naturally support Enter activation. Custom interactive components (dropdowns, modals) require explicit keyboard event handling. Relates to US-096, US-097.
