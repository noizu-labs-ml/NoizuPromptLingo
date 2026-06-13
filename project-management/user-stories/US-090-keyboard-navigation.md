---
id: US-090
title: "Full keyboard navigation on companion site"
slug: "keyboard-navigation"
personas: [P-003, P-001, P-007]
epic: "Accessibility & Internationalization"
priority: "should-have"
complexity: "M"
tags: [accessibility, keyboard, a11y, wcag]
---

# US-090: Full keyboard navigation on companion site

## User Story

**As a** UX Designer (P-003),
**I want to** navigate the entire companion site using only a keyboard,
**So that** the product is accessible to users with motor impairments and meets WCAG 2.1 AA standards.

## Acceptance Criteria

- [ ] Given any interactive element on the page, when navigating with Tab and Shift+Tab, then focus moves predictably through all focusable elements in DOM order
- [ ] Given a modal or dropdown is open, when the user presses Escape, then the modal/dropdown closes and focus returns to the triggering element
- [ ] Given a focus indicator is applied to any element, when the element receives focus, then a visible focus ring is rendered with sufficient contrast (3:1 minimum against adjacent colors)

## Notes

All custom components (mockup cards, tag inputs, filter panels) must be keyboard-operable. Run automated a11y checks with axe-core as part of CI. Complements US-091 (screen reader support).
