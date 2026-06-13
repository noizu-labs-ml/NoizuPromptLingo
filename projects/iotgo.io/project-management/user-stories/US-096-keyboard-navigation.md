---
id: US-096
title: "Keyboard Navigation"
slug: "keyboard-navigation"
personas: [P-001, P-008]
epic: "Accessibility, Performance & Edge Cases"
priority: "should-have"
complexity: "M"
tags: [accessibility, keyboard, a11y, wcag]
---

# US-096: Keyboard Navigation

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** navigate and operate the entire IoTGo interface using only a keyboard,
**So that** I can work efficiently in keyboard-first workflows and the platform meets WCAG 2.1 AA accessibility requirements.

## Acceptance Criteria

- [ ] Given the application is loaded, when I press Tab, then focus moves sequentially through all interactive elements in a logical reading order with a visible focus indicator
- [ ] Given a dropdown menu or modal is open, when I press Escape, then the element closes and focus returns to the trigger element
- [ ] Given a data table is focused, when I press arrow keys, then I can navigate between table cells and rows without a mouse
- [ ] Given a form is displayed, when I use keyboard-only navigation and submit the form, then all validation errors are announced and focus moves to the first error field
- [ ] Given any interactive widget (date picker, multi-select, toggle), when operated via keyboard, then behavior is consistent with ARIA authoring practices guide patterns for that widget type

## Notes

Focus trapping must be implemented correctly in modals and slide-over panels. Relates to US-097 (screen reader support). Keyboard shortcuts for power users (e.g., `/` to focus search) are a separate enhancement.
