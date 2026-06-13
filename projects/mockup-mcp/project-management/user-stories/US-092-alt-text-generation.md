---
id: US-092
title: "Alt-text generation for mockup images"
slug: "alt-text-generation"
personas: [P-003, P-007, P-001]
epic: "Accessibility & Internationalization"
priority: "should-have"
complexity: "M"
tags: [accessibility, alt-text, ai, images, a11y]
---

# US-092: Alt-text generation for mockup images

## User Story

**As a** UX Designer (P-003),
**I want to** have alt-text automatically generated for image-based mockups,
**So that** screen reader users and search engines receive meaningful descriptions without requiring manual entry for every mockup.

## Acceptance Criteria

- [ ] Given an image mockup is generated, when the generation completes, then an AI-generated alt-text description is automatically attached to the mockup and stored in the database
- [ ] Given an auto-generated alt-text exists, when the mockup is displayed, then the `<img>` element's `alt` attribute is populated with the generated description
- [ ] Given I am an author viewing a mockup, when I open the accessibility settings panel, then I can review and override the auto-generated alt-text with my own description

## Notes

Alt-text generation can reuse the same AI provider used for image generation or use a dedicated captioning model. User overrides take precedence over auto-generated text. Diagram-type mockups (SVG, PlantUML, Mermaid) should use their text source as the basis for alt-text rather than AI captioning.
