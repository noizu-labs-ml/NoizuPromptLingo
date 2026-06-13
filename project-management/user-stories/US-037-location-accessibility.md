---
id: US-037
title: "Location accessibility descriptions"
slug: "location-accessibility"
personas: [P-005]
epic: "World State Manager"
priority: "should-have"
complexity: "M"
tags: [world-state, accessibility, locations, screen-reader, inclusive-design]
---

# US-037: Location Accessibility Descriptions

## User Story

**As a** blind game developer building screen-reader-friendly RPGs (P-005),
**I want to** attach structured accessibility descriptions to locations that describe spatial layout, navigation cues, and sensory details (sound, texture, smell) beyond visual appearance,
**So that** players using screen readers or audio-only interfaces receive rich, orientating location descriptions from the Narrative Engine.

## Acceptance Criteria

- [ ] Given a location definition, when I add an `accessibility` block with fields `audio_cue`, `spatial_description`, `navigation_hints`, and `sensory_details`, then all fields are stored and returned via `world.get_location(id)`.
- [ ] Given a location with an accessibility block, when the Narrative Engine assembles context with `accessibility_mode=True`, then the `spatial_description` and `sensory_details` are promoted to the primary description slot instead of the visual description.
- [ ] Given a location missing an accessibility block, when `accessibility_mode=True` is set, then the framework logs a `MissingAccessibilityData` warning (not an error) and falls back to the standard description.
- [ ] Given navigation hints defined as an ordered list (e.g. `["door to north", "well to east", "stairs down"]`), when context is assembled, then hints are rendered as a numbered list suitable for sequential screen-reader consumption.
- [ ] Given a world loaded from YAML, when location definitions include `accessibility` keys, then they are parsed and available without additional configuration.

## Notes

P-005 (Tomás Rivera) is the edge-case persona driving inclusive design requirements. Accessibility blocks are additive — they do not replace existing location properties. This story ensures NoizuRPG can be used to build WCAG-adjacent accessible game experiences, broadening the developer audience.
