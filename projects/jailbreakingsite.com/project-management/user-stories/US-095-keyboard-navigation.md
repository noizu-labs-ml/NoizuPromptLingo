---
id: US-095
title: "Navigate Entire Site via Keyboard"
slug: "keyboard-navigation"
personas: [P-001, P-004, P-006]
epic: "Accessibility & Performance"
priority: "should-have"
complexity: "M"
tags: [accessibility, keyboard, wcag, a11y, ux]
---

# US-095: Navigate Entire Site via Keyboard

## User Story

**As a** power user or accessibility-dependent user (P-001, P-004, P-006),
**I want to** navigate all core platform functionality using only a keyboard,
**So that** I am not blocked from using the platform due to motor impairment, personal preference for keyboard workflows, or screen reader dependency.

## Acceptance Criteria

- [ ] Given any page on the platform, when I press Tab, then focus moves through interactive elements in a logical DOM order with a visible focus indicator on each element
- [ ] Given modal dialogs or flyout panels, when they open, then focus is trapped inside the dialog and restored to the trigger element when the dialog closes
- [ ] Given dropdown menus and filter panels, when I navigate them with arrow keys, then items are selectable and Enter activates the selection
- [ ] Given the global search bar, when I press a designated keyboard shortcut (e.g., `/` or `Cmd+K`), then focus jumps to the search input from any page
- [ ] Given data tables (catalog list, scan results), when I navigate with keyboard, then I can sort columns, activate row actions, and expand row details without a mouse
- [ ] Given skip-navigation links, when the page loads, then a "Skip to main content" link is the first focusable element and correctly bypasses the header nav

## Notes

WCAG 2.1 AA compliance is the target baseline. Focus indicator must have a minimum 3:1 contrast ratio against adjacent background (WCAG 2.1 criterion 1.4.11). All custom interactive components (technique cards, scan progress, lab cards) must implement ARIA roles and keyboard event handlers. Audit with axe-core as part of CI.
