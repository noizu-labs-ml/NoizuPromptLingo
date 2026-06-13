---
id: US-025
title: "Download mockup in multiple formats"
slug: "download-mockup-formats"
personas: [P-001, P-002, P-003, P-006]
epic: "Mockup Management"
priority: "must-have"
complexity: "S"
tags: [mockup-management, download, export, formats]
---

# US-025: Download mockup in multiple formats

## User Story

**As a** product manager (P-002),
**I want to** download a generated mockup in the format that matches my destination (Confluence doc, Figma import, dev handoff),
**So that** I can share and embed artifacts in the tools my team already uses without manual conversion.

## Acceptance Criteria

- [ ] Given a wireframe mockup, when I click "Download", then a format picker offers SVG, PNG (1x, 2x), and PDF options
- [ ] Given a diagram mockup, when I click "Download", then the format picker additionally offers the source markup format (Mermaid `.md` or PlantUML `.puml`) that was used to generate it
- [ ] Given I select PNG 2x, when the download completes, then the file is a raster image at double the original resolution with the mockup name as the filename
- [ ] Given I select PDF, when the download completes, then the PDF contains the mockup on a single page at A4 size with the mockup name and creation date in the footer

## Notes

SVG downloads include embedded fonts to prevent rendering differences across environments. Bulk download (multiple mockups as a ZIP) is a future enhancement. Download counts are tracked for quota reporting but do not consume generation quota. Related to US-019, US-004.
