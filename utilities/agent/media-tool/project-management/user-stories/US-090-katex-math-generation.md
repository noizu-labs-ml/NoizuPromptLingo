---
id: US-090
title: "Generate KaTeX math expressions"
slug: katex-math-generation
personas: [P-002]
epic: "Diagram & Text Formats"
priority: could-have
complexity: low
tags: [math, katex, latex, expression]
---

# US-090: Generate KaTeX math expressions

## User Story

**As a** technical writer including math in articles
**I want to** generate KaTeX-compatible math expressions from text descriptions
**So that** I can include properly rendered equations in my articles

## Acceptance Criteria

- **Given** a `.media.prompt` with `text_format: katex`
  **When** generation runs
  **Then** a `.tex` file is produced with valid KaTeX-compatible math markup

## Notes
KaTeX is a subset of LaTeX. The generated markup should be KaTeX-compatible for web rendering.
