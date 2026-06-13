---
id: US-075
title: "Dark Mode / Theme Toggle"
slug: "dark-mode-theme-toggle"
personas: [P-001, P-002, P-003, P-005, P-006, P-008]
epic: "Settings & Preferences"
priority: "could-have"
complexity: "S"
tags: [settings, dark-mode, theme, ui, accessibility]
---

# US-075: Dark Mode / Theme Toggle

## User Story

**As an** indie developer (P-005),
**I want to** switch between light and dark themes,
**So that** I can use the platform comfortably in different lighting conditions and personal preferences.

## Acceptance Criteria

- [ ] Given any page, when I click the theme toggle control, then the site switches between light and dark modes immediately without a full page reload
- [ ] Given I am authenticated and set a theme preference, when I log in on a different device or browser, then my saved theme preference is applied
- [ ] Given I have not set a theme preference, when the site loads, then it respects my operating system's prefers-color-scheme setting
- [ ] Given I am unauthenticated and toggle the theme, when I reload the page, then my preference is persisted via localStorage so it survives the session

## Notes

Implement via CSS custom properties and a data-theme attribute on the root element for clean, performant toggling. Theme preference should be stored both in localStorage (for unauthenticated persistence) and in user account settings (for cross-device sync). WCAG contrast ratios must be maintained in both themes.
