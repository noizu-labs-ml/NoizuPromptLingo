---
id: US-078
title: "Configure renderer theme and options"
slug: theme-configuration-for-renderers
personas: [P-002, P-001]
epic: "Renderers"
priority: should-have
complexity: low
tags: [renderer, theme, configuration, mermaid]
---

# US-078: Configure renderer theme and options

## User Story

**As a** developer generating diagrams for dark-themed documentation
**I want to** configure the renderer theme (dark, light, custom)
**So that** rendered diagrams match my documentation's visual style

## Acceptance Criteria

- **Given** `post_processing.params.theme: dark`
  **When** Mermaid rendering runs
  **Then** the dark theme is applied via `-t dark`

- **Given** a custom CSS file for rendering
  **When** `params.css: ./custom.css` is specified
  **Then** the custom CSS is applied to the rendered diagram

## Notes
Theme options are renderer-specific. Mermaid: default, dark, forest, neutral. PlantUML: via `!theme` directive.
