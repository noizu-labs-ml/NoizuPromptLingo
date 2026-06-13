---
id: US-065
title: "Set default design system/theme for new mockups"
slug: "set-default-design-system-theme"
personas: [P-003, P-006]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "S"
tags: [settings, theme, design-system, preferences, default]
---

# US-065: Set Default Design System/Theme for New Mockups

## User Story

**As a** UX Designer (P-003),
**I want to** set a default design system or theme in my account settings,
**So that** all my mockup generations automatically use my team's design language without specifying it per request.

## Acceptance Criteria

- [ ] Given the settings page, when I select a built-in theme or a previously uploaded custom theme as my default, then the selection is saved to my profile
- [ ] Given my default theme is set, when I make a generation request without specifying a theme, then my default theme is applied to the output
- [ ] Given I have a workspace default (US-067) and a personal default set, when generating, then the personal default takes precedence over the workspace default
- [ ] Given I want to clear my default theme, when I select "None / system default", then subsequent requests use the neutral wireframe style unless overridden at request time

## Notes

Pairs with US-055 (theme application at generation time) and US-067 (workspace-level defaults). The precedence order is: request-level → personal default → workspace default → system neutral.
