---
id: US-085
title: "High Contrast Mode"
slug: "high-contrast-mode"
personas: [P-001, P-002, P-003, P-008]
epic: "Accessibility & i18n"
priority: "could-have"
complexity: "M"
tags: [accessibility, high-contrast, visual-impairment, theme, wcag, a11y]
---

# US-085: High Contrast Mode

## User Story

**As an** AI Newcomer (P-008) or any user with low vision,
**I want to** enable a high contrast display mode,
**So that** text and interactive elements are legible against their backgrounds even in challenging lighting conditions or with visual impairments.

## Acceptance Criteria

- [ ] Given a user's OS or browser is set to prefer high contrast (prefers-contrast: more), when they load the site, then a high contrast theme is automatically applied
- [ ] Given a user wants to manually override the contrast setting, when they toggle high contrast in their accessibility preferences, then the theme switches immediately and persists across sessions
- [ ] Given high contrast mode is active, when any page is rendered, then all text meets WCAG AA contrast ratio requirements (4.5:1 for normal text, 3:1 for large text) against its background
- [ ] Given high contrast mode is active, when focus rings, borders, and icon-only buttons are rendered, then they remain clearly distinguishable with at least 3:1 contrast ratio against adjacent colors

## Notes

High contrast mode should be implemented as a CSS class on the root element plus a media query listener for `prefers-contrast`. Avoid using images to convey meaning that would be lost when high contrast alters colors. Preference should be stored in user account settings when logged in, and localStorage when anonymous.
