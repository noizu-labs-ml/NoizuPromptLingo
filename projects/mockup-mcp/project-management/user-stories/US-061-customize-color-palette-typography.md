---
id: US-061
title: "Customize color palette and typography in generation"
slug: "customize-color-palette-typography"
personas: [P-003, P-006]
epic: "Diagram & Rendering Engine"
priority: "should-have"
complexity: "S"
tags: [color, typography, customization, theme, rendering]
---

# US-061: Customize Color Palette and Typography in Generation

## User Story

**As a** Freelance Consultant (P-006),
**I want to** specify exact brand colors and font choices inline in my generation request,
**So that** one-off client mockups match brand guidelines without creating and managing a full saved theme.

## Acceptance Criteria

- [ ] Given a generation request with inline `colors` (primary, secondary, background, text) and `fonts` (heading, body) parameters, when processed, then the generated output reflects those values
- [ ] Given a hex color value is invalid (e.g., `#ZZZZZZ`), when submitted, then a validation error is returned before generation begins
- [ ] Given a font name that is not in the system's available font list, when submitted, then the system falls back to the closest available font and notes the substitution in the response
- [ ] Given both an inline style override and a theme ID in the same request, when processed, then inline overrides take precedence over the theme for conflicting properties

## Notes

Inline overrides are lighter-weight than full theme management (US-055, US-065). The override-wins-over-theme precedence rule must be consistently enforced across all rendering backends (SVG, PlantUML, image AI).
