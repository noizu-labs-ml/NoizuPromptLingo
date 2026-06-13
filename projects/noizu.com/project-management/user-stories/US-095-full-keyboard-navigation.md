---
id: US-095
title: "Full Keyboard Navigation for All Interactive Elements"
slug: "full-keyboard-navigation"
personas: [P-001, P-002, P-003, P-004, P-005, P-006, P-007, P-008]
epic: "Accessibility & i18n"
priority: "must-have"
complexity: "L"
tags: [accessibility, keyboard-navigation, wcag, a11y, focus-management]
---

# US-095: Full Keyboard Navigation for All Interactive Elements

## User Story

**As a** user who relies on keyboard navigation,
**I want to** operate all interactive elements on the site using only a keyboard,
**So that** I can access the full site without a mouse or touch device and comply with WCAG 2.1 AA requirements.

## Acceptance Criteria

- [ ] Given any interactive element (links, buttons, form inputs, dropdowns, modals, tabs), when navigated to via Tab key, then the element receives a visible focus indicator meeting WCAG 2.1 AA contrast requirements
- [ ] Given a modal or dialog opened by keyboard action, when the modal opens, then focus is moved into the modal and Tab cycles within it; focus does not escape to the page behind
- [ ] Given a modal that is dismissed, when closed, then focus returns to the element that triggered it
- [ ] Given dropdown menus or disclosure widgets, when activated via Enter or Space, then the menu opens and arrow keys navigate items; Escape closes it and returns focus
- [ ] Given the site header navigation on mobile, when a keyboard user activates the hamburger menu, then the menu opens and all links are reachable via Tab
- [ ] Given skip-navigation links, when a keyboard user first tabs into a page, then a "Skip to main content" link is the first focusable element

## Notes

Audit tool: axe-core automated scan + manual keyboard walkthrough. Components most likely to need work: custom dropdowns, modals (US-077 citation modal), tab panels (settings pages). Focus trap utility should be a shared component. Related to US-096 (screen reader), US-097 (high-contrast mode). Acceptance means zero WCAG 2.1 AA keyboard failures on axe audit.
