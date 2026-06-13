---
id: US-083
title: "User selects preferred theme"
slug: "theme-selection"
personas: [P-001, P-007]
epic: "Settings & Preferences"
priority: "could-have"
complexity: "S"
tags: [settings, theme, ui-preferences, dark-mode, accessibility]
---

# US-083: User Selects Preferred Theme

## User Story

**As a** Solo AI Hobbyist (P-007),
**I want to** select my preferred visual theme from the available options (Bold, Enterprise, Minimal, Nocturne),
**So that** the platform matches my visual preference and reduces eye strain during extended sessions.

## Acceptance Criteria

- [ ] Given a user navigates to Settings > Appearance, when the theme selector loads, then all four themes (Bold, Enterprise, Minimal, Nocturne) are displayed with a live preview swatch showing key UI elements in that theme
- [ ] Given a user selects a theme, when the selection is saved, then the entire platform UI immediately updates to reflect the chosen theme without requiring a page reload
- [ ] Given a user has selected a theme, when they log out and log back in, then their theme preference is persisted and applied on load
- [ ] Given a user has not explicitly selected a theme, when they first visit the platform, then the system applies Nocturne as the default if the browser reports a prefers-color-scheme: dark media query, otherwise applies Minimal

## Notes

Themes are defined in YAML and compiled to CSS via the styleguide engine. The four themes correspond to distinct visual identities: Bold (vibrant, high-contrast), Enterprise (professional, muted), Minimal (clean, neutral), Nocturne (dark mode). This is a low-complexity feature because the theming infrastructure already exists in the design system.
