---
id: US-008
title: "Accessibility — WCAG 2.1 AA Compliance"
slug: "accessibility-wcag-compliance"
personas: [P-001, P-002, P-003, P-006]
epic: "Public Portfolio"
priority: "should-have"
complexity: "M"
tags: [accessibility, wcag, a11y, keyboard-nav, screen-reader]
---

# US-008: Accessibility — WCAG 2.1 AA Compliance

## User Story

**As a** visitor using a screen reader or keyboard-only navigation,
**I want to** access all content and complete all key interactions without a mouse,
**So that** I am not excluded from evaluating or contacting Keith's consulting services.

## Acceptance Criteria

- [ ] Given any page, when navigated with Tab/Shift-Tab, then all interactive elements receive visible focus rings and are reachable in logical DOM order.
- [ ] Given any image on the site, when inspected, then meaningful images have descriptive alt text and decorative images have empty alt (`alt=""`).
- [ ] Given the navigation and landmark regions, when inspected with a screen reader (VoiceOver/NVDA), then `<nav>`, `<main>`, `<footer>` landmarks are present and labeled.
- [ ] Given color is used to convey information (e.g., active nav link), when viewed, then a non-color indicator (underline, icon, bold) is also present.
- [ ] Given the site is run through axe-core or Lighthouse accessibility audit, when the report is generated, then zero critical violations are flagged.
- [ ] Given any form field (contact form, auth forms), when rendered, then each input has an associated `<label>` and error messages are linked via `aria-describedby`.

## Notes

Aim for WCAG 2.1 AA as the baseline. AAA is aspirational. Run automated checks in CI via `axe-playwright` or similar. Color contrast ratio must be ≥ 4.5:1 for normal text. Related: US-006 (mobile/touch targets), US-011 (contact form).
