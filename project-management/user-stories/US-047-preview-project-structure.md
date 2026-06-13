---
id: US-047
title: "Preview generated project structure before download"
slug: "preview-project-structure"
personas: [P-001, P-007]
epic: "MCP Jumpstart"
priority: "should-have"
complexity: "M"
tags: [mcp-jumpstart, scaffolding, preview, ux]
---

# US-047: Preview Generated Project Structure Before Download

## User Story

**As a** Solo AI Hobbyist (P-007),
**I want to** preview the generated project structure and key files before downloading,
**So that** I can verify the scaffold matches my expectations and avoid downloading a project I will immediately discard.

## Acceptance Criteria

- [ ] Given the user has configured all generation options (US-039, US-040, US-048), when the preview step loads, then the system displays an interactive file tree showing the complete project directory structure.
- [ ] Given the file tree is displayed, when the user clicks on a file, then a read-only code preview panel shows the generated file contents with syntax highlighting appropriate to the language.
- [ ] Given the file tree is displayed, when the user collapses or expands directories, then the tree state persists and they can navigate the full structure without losing context.
- [ ] Given the user is previewing the project, when they view the summary panel, then it shows the total file count, the list of generated tools, the selected transport types, and the estimated project size.
- [ ] Given the preview is displayed, when the user modifies any generation option, then the preview regenerates and the file tree updates to reflect the change.
- [ ] Given the user is satisfied with the preview, when they click "Download" or "Push to Git," then the system proceeds to US-049 or US-050 using the exact configuration shown in the preview.

## Notes

The preview is a confidence-building step that reduces wasted downloads. The file tree should use standard UI patterns (expand/collapse, click to view). Preview regeneration should be fast (under 2 seconds). Related: US-041 (generation), US-048 (customization), US-049 (download).
