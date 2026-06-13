---
id: US-069
title: "Dark mode / light mode toggle on companion site"
slug: "dark-mode-light-mode-toggle"
personas: [P-003, P-002, P-006]
epic: "Settings & Preferences"
priority: "could-have"
complexity: "S"
tags: [dark-mode, ui, companion-site, accessibility, preferences]
---

# US-069: Dark Mode / Light Mode Toggle on Companion Site

## User Story

**As a** UX Designer (P-003),
**I want to** switch the companion website between dark and light mode,
**So that** I can work comfortably in my preferred visual environment, especially during extended review sessions.

## Acceptance Criteria

- [ ] Given the companion site header or settings page, when I toggle the color scheme, then the entire UI immediately switches between dark and light mode without a page reload
- [ ] Given I set a color scheme preference, when I return to the site in a new session, then my preference is restored (persisted in local storage or account settings)
- [ ] Given the user's OS is set to dark mode, when I visit the site for the first time, then dark mode is applied by default before any explicit user choice
- [ ] Given dark mode is active, when viewing a generated wireframe or mockup, then the mockup itself is displayed in its original colors (not inverted or filtered by the dark mode)

## Notes

OS preference detection uses the `prefers-color-scheme` media query. Mockup images must remain unaffected by the UI color scheme — render them in an isolated container. Implementation is CSS custom property + class toggle on `<html>`.
