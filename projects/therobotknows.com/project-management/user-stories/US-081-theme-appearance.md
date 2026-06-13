---
id: US-081
title: "Theme & Appearance Customization"
slug: "theme-appearance"
personas: [P-001, P-002, P-004, P-005, P-008]
epic: "Settings & Preferences"
priority: "could-have"
complexity: "S"
tags: [settings, theme, dark-mode, ui, appearance]
---

# US-081: Theme & Appearance Customization

## User Story

**As a** user who spends long sessions in the platform (P-001, P-002, P-004, P-005, P-008),
**I want to** switch between light, dark, and system-default themes and adjust the editor font size,
**So that** I can work comfortably across different lighting conditions and reduce eye strain.

## Acceptance Criteria

- [ ] Given I am on Settings > Appearance, when I select "Dark mode," then the entire application immediately switches to a dark color scheme without a page reload.
- [ ] Given I select "System default," when my OS switches between light and dark mode, then the application follows automatically using the `prefers-color-scheme` media query.
- [ ] Given I adjust the editor font size slider, when I open the Canon Editor, then the body text renders at my selected size (range: 12px–24px).
- [ ] Given I save my appearance preferences, when I log in from a different browser, then my theme and font size preferences are applied from my account settings (not just local storage).
- [ ] Given I have not set a theme preference, when I first visit the app, then the system default (OS preference) is used.

## Notes

Theme tokens must be CSS custom properties to enable instant switching. Related: US-096 (accessibility). High-contrast mode should be considered as a follow-on under the accessibility epic.
