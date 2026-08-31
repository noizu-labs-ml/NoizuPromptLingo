---
id: US-039
title: "High-contrast / reduced-motion theme"
slug: high-contrast-reduced-motion-theme
personas: [P-007]
epic: "Accessibility & i18n"
priority: could-have
complexity: low
tags: [accessibility, theming]
---

# US-039: High-Contrast / Reduced-Motion Theme

## User Story

**As a** novice occasional user
**I want to** enable a theme option that provides higher-contrast colors and disables non-essential animation
**So that** I can read the web UI comfortably if standard color contrast or motion effects make the interface hard to use

## Acceptance Criteria

- **Given** I open Settings
  **When** I enable "High contrast / reduced motion"
  **Then** the UI switches to a higher-contrast color palette (meeting at least WCAG AA contrast ratios) across search, browse, and thread viewer

- **Given** the theme is enabled
  **When** any UI element would normally animate (e.g. collapse/expand transitions, loading spinners)
  **Then** non-essential animations are disabled or reduced to an instant/near-instant state

- **Given** my OS-level `prefers-reduced-motion` setting is already enabled
  **When** I load the app without explicitly setting the in-app theme
  **Then** the app respects the OS preference by default for motion (contrast still requires the explicit in-app toggle)

## Notes
Deferred to could-have — a valuable accessibility affordance for Jamie but scoped after the higher-priority keyboard navigation (US-037) and ARIA labeling (US-038) stories that address more fundamental usability blockers first. Low complexity: primarily a CSS theme variant plus a media-query check for motion preference.
