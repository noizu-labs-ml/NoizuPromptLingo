---
id: US-097
title: "Dark Mode Toggle"
slug: "dark-mode-toggle"
personas: [P-001, P-002, P-004]
epic: "Accessibility & Performance"
priority: "should-have"
complexity: "S"
tags: [accessibility, dark-mode, ui, preferences, ux]
---

# US-097: Dark Mode Toggle

## User Story

**As a** Web Nostalgia Explorer (P-001),
**I want to** toggle between light and dark mode,
**So that** I can browse comfortably during late-night link-following sessions without eye strain.

## Acceptance Criteria

- [ ] Given any page on gotta.cc is loaded, when I click the dark/light mode toggle in the navigation or settings, then the entire UI switches to the selected theme without a page reload
- [ ] Given I have selected dark mode, when I navigate to another page or return to the site in a new session, then dark mode is still active (preference is persisted in localStorage or account settings)
- [ ] Given the site respects the OS-level preference, when `prefers-color-scheme: dark` is active in my system settings, then dark mode is applied automatically on first visit before I interact with the toggle
- [ ] Given dark mode is active, when I inspect any text element, then contrast ratios meet WCAG 2.1 AA standards (4.5:1 for body text, 3:1 for large text) in dark mode as well as light mode
- [ ] Given a logged-in user has set a theme preference, when they log in on a different device, then the theme preference is applied from their account settings

## Notes

Use CSS custom properties (variables) for all color tokens to make theme switching instant and maintainable. The `prefers-color-scheme` media query should be the default; the manual toggle overrides it. Dark mode is a WCAG 2.1 accessibility recommendation for users with photosensitivity. Score visualizations and charts must be theme-aware.
