---
id: US-059
title: "Generate LaTeX and Typst documents"
slug: latex-document-generation
personas: [P-002]
epic: "Diagram & Text Formats"
priority: could-have
complexity: medium
tags: [document, latex, typst, pdf]
---

# US-059: Generate LaTeX and Typst documents

## User Story

**As a** technical writer producing formal documentation
**I want to** generate LaTeX or Typst documents from text descriptions
**So that** I can produce publication-quality PDFs with equations and figures

## Acceptance Criteria

- **Given** a `.media.prompt` with `text_format: latex`
  **When** generation runs
  **Then** a `.tex` file is produced with valid LaTeX markup

- **Given** `text_format: typst`
  **When** generation runs
  **Then** a `.typ` file is produced with valid Typst markup

## Notes
Render to PDF is a separate post-processing step via `pdflatex` or `typst` CLI.
