---
id: US-094
title: "Switch to the High-Contrast Nocturne Theme"
slug: "high-contrast-dark-theme-switch"
personas: [P-008, P-001]
epic: "Accessibility & Internationalization"
priority: "should-have"
complexity: "S"
tags: [theming, accessibility, dark-mode, contrast]
---

# US-094: Switch to the High-Contrast Nocturne Theme

## User Story

**As** Jordan Vance, the Harness Operator (P-001),
**I want to** switch to the `npl-nocturne` high-contrast dark theme,
**So that** extended screen time watching agent output is more comfortable and status colors remain distinguishable in low light.

## Acceptance Criteria

- [ ] Given Jordan opens theme settings, when he selects `npl-nocturne`, then the entire dashboard — ticket board, chat, and wiki views — re-renders in that theme without a page reload.
- [ ] Given `npl-nocturne` is active, when its text/background pairs are checked against WCAG AA contrast ratios, then all four shipped themes, including this one, meet or exceed the minimum ratio.
- [ ] Given a user selects a theme, when they close and reopen the app in a new session, then their theme choice persists as a per-user preference, not per-tab.
- [ ] Given Tomás (P-008) has an OS-level preference for dark mode and no saved in-app preference, when he first loads the app, then it defaults to a dark-capable theme instead of forcing light mode.

## Notes

All four YAML-driven themes (`npl-nocturne`, `npl-brutalist`, `npl-editorial`, `npl-minimal`) must ship, but this story's criteria focus on the switching mechanism and the contrast guarantee for the high-contrast option specifically.
