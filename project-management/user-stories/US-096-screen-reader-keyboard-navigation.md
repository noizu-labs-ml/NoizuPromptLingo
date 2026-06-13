---
id: US-096
title: "Screen Reader & Keyboard Navigation Accessibility"
slug: "screen-reader-keyboard-navigation"
personas: [P-001, P-002, P-003, P-004, P-005, P-008]
epic: "Accessibility, i18n & Performance"
priority: "must-have"
complexity: "L"
tags: [accessibility, a11y, wcag, keyboard, screen-reader, aria]
---

# US-096: Screen Reader & Keyboard Navigation Accessibility

## User Story

**As a** user who relies on assistive technology (P-001, P-002, P-003, P-004, P-005, P-008),
**I want to** navigate the entire platform using only a keyboard and have all interactive elements properly announced by screen readers,
**So that** the platform is usable regardless of my physical or visual abilities.

## Acceptance Criteria

- [ ] Given I am navigating with a keyboard only, when I tab through any page, then focus order follows a logical reading order and a visible focus ring is present on every interactive element at all times.
- [ ] Given I use a screen reader (NVDA/VoiceOver), when I encounter an icon-only button, then the button has an `aria-label` describing its function.
- [ ] Given a modal dialog opens (e.g., delete confirmation), when focus moves into the modal, then it is trapped within the modal until I close it, and focus returns to the trigger element on close.
- [ ] Given the knowledge graph visualization is displayed, when I access it with a keyboard, then I can navigate between nodes using arrow keys and each node's label and connection count are announced.
- [ ] Given the platform is audited against WCAG 2.1 AA standards, when automated tests and a manual review are conducted, then zero critical (A/AA) violations are found.

## Notes

Accessibility must be treated as a first-class requirement, not a bolt-on. WCAG 2.1 AA is the minimum standard. The D3.js knowledge graph (US-026) requires special handling — consider an accessible table fallback. Related: US-081 (theme/appearance) — high-contrast mode support should be co-developed.
