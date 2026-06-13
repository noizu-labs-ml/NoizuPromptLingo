---
id: US-056
title: "Generate mockup from screenshot reference image"
slug: "generate-mockup-from-screenshot"
personas: [P-003, P-006, P-004]
epic: "Diagram & Rendering Engine"
priority: "should-have"
complexity: "XL"
tags: [image-input, screenshot, ai-generation, reference, vision]
---

# US-056: Generate Mockup from Screenshot Reference Image

## User Story

**As a** UX Designer (P-003),
**I want to** upload a screenshot of an existing UI and receive a clean wireframe recreation,
**So that** I can rapidly produce editable mockup assets from live product screenshots or competitor references.

## Acceptance Criteria

- [ ] Given an image upload (PNG, JPG, WebP) via MCP tool call, when processed, then a wireframe representation of the UI in the image is returned
- [ ] Given the screenshot contains text labels, when wireframed, then placeholder labels or extracted text are preserved in the output
- [ ] Given an image that is not a UI screenshot (e.g., a photo), when submitted, then the system returns a warning but still attempts generation or gracefully declines with a clear message
- [ ] Given image size exceeds the configured limit (default: 10 MB), when submitted, then a 413-equivalent error is returned before processing begins

## Notes

Requires a multimodal vision model in the generation pipeline. This is the highest-complexity story in the epic — implementation depends on the AI provider supporting image input. Related to US-051.
