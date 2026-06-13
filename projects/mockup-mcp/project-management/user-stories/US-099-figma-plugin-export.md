---
id: US-099
title: "Figma plugin export (import mockup into Figma)"
slug: "figma-plugin-export"
personas: [P-003, P-001]
epic: "Integration & API"
priority: "won't-have-yet"
complexity: "XL"
tags: [figma, export, integration, design]
---

# US-099: Figma plugin export (import mockup into Figma)

## User Story

**As a** UX Designer (P-003),
**I want to** export a generated mockup directly into a Figma file via a plugin,
**So that** I can use AI-generated wireframes as a starting point in my existing Figma design workflow without manual copy-paste.

## Acceptance Criteria

- [ ] Given the Figma plugin is installed and I am authenticated, when I browse my mockups from within Figma, then I see a list of my recent mockups with previews
- [ ] Given I select a mockup to import, when I click "Insert into Figma", then the mockup is placed as a frame or image on the current Figma canvas at the cursor position
- [ ] Given the mockup is an SVG diagram, when it is inserted into Figma, then it is imported as a vector layer rather than a rasterized image, preserving editability

## Notes

Requires building and publishing a Figma plugin to the Figma Community marketplace. Figma Plugin API access and OAuth flow need to be designed. SVG import as editable vector is subject to Figma Plugin API capabilities — validate feasibility before committing to acceptance criteria. This is the highest complexity item in the integration epic and is deferred to a later release cycle.
