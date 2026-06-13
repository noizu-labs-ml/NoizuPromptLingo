---
id: US-097
title: "High-Contrast & Reduced-Motion Modes"
slug: "high-contrast-reduced-motion-modes"
personas: [P-001, P-002, P-003, P-004, P-005, P-006, P-007, P-008]
epic: "Accessibility & i18n"
priority: "should-have"
complexity: "M"
tags: [accessibility, high-contrast, reduced-motion, wcag, a11y, css]
---

# US-097: High-Contrast & Reduced-Motion Modes

## User Story

**As a** user with visual sensitivity or vestibular disorder,
**I want** the site to respect my operating-system preferences for high-contrast display and reduced motion,
**So that** I can use the site comfortably without triggering visual discomfort or accessibility barriers.

## Acceptance Criteria

- [ ] Given a user's OS is set to prefer high-contrast (Windows High Contrast Mode or `prefers-contrast: more`), when the site loads, then text and interactive elements maintain sufficient contrast and custom color overrides yield to the system palette
- [ ] Given a user's OS is set to prefer reduced motion (`prefers-reduced-motion: reduce`), when animations or transitions would play, then they are either disabled or replaced with instant/opacity-only alternatives
- [ ] Given the reduced-motion preference active, when page transitions, loading spinners, or scroll-triggered animations fire, then no transform or position-based animation plays
- [ ] Given the high-contrast preference, when focus indicators are rendered, then they remain visible and use high-contrast-safe colors (not relying solely on color to convey state)
- [ ] Given both preferences simultaneously active, when the site renders, then both sets of overrides apply without conflict
- [ ] Given the site's own dark/light mode toggle, when switched, then WCAG AA contrast ratios (4.5:1 text, 3:1 UI components) are met in both modes

## Notes

Implementation: CSS `@media (prefers-reduced-motion: reduce)` and `@media (prefers-contrast: more)` blocks. Audit all CSS animations and transitions for reduced-motion compliance. Use `gap` and `transform: translateZ(0)` sparingly. Related to US-095 (keyboard nav), US-096 (screen reader). No manual toggle needed — OS preference detection is sufficient for phase 1.
