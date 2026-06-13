---
id: US-055
title: "Apply a design system/theme to generated mockups"
slug: "apply-design-system-theme"
personas: [P-003, P-001, P-006]
epic: "Diagram & Rendering Engine"
priority: "should-have"
complexity: "M"
tags: [theme, design-system, styling, brand]
---

# US-055: Apply a Design System/Theme to Generated Mockups

## User Story

**As a** Freelance Consultant (P-006),
**I want to** specify a design system or theme when generating mockups,
**So that** client deliverables match the client's brand without post-generation manual restyling.

## Acceptance Criteria

- [ ] Given a theme name or theme config object passed in the MCP request, when the mockup is generated, then the output reflects the specified color palette, typography, and component styles
- [ ] Given a built-in theme (e.g., "material", "fluent", "tailwind-default"), when selected, then the mockup uses that system's visual language
- [ ] Given a custom theme YAML/JSON uploaded by the user, when referenced by ID in the request, then that theme is applied to the generated output
- [ ] Given no theme is specified, when generating, then the user's default theme preference (US-065) is used, falling back to a neutral wireframe style

## Notes

Connects to US-065 (default theme preference) and the design system YAML convention used in the incubator styleguide-engine. Custom theme storage is managed by the Phoenix backend.
