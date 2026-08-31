---
id: US-032
title: "Inline LaTeX rendering"
slug: inline-latex-rendering
personas: [P-003]
epic: "Thread Viewer"
priority: could-have
complexity: medium
tags: [viewer, latex]
---

# US-032: Inline LaTeX Rendering

## User Story

**As an** ML fine-tuning engineer
**I want to** see LaTeX math expressions — both inline and block — rendered as formatted equations in the thread viewer
**So that** I can read training-data discussions involving loss functions, gradients, or statistical notation without mentally parsing raw LaTeX source

## Acceptance Criteria

- **Given** a message contains inline LaTeX delimited with `$...$` (e.g. a loss function reference)
  **When** the thread viewer renders it
  **Then** the expression renders as formatted inline math within the surrounding text

- **Given** a message contains block LaTeX delimited with `$$...$$`
  **When** rendered
  **Then** it renders as a centered, standalone formatted equation block

- **Given** a LaTeX expression has invalid syntax
  **When** rendering is attempted
  **Then** the viewer falls back to showing the raw LaTeX text rather than breaking the rest of the message's rendering

## Notes
Could-have and deferred relative to Markdown/code/Mermaid — LaTeX is niche to Elena's ML-focused threads rather than a need shared broadly across personas, so it's lower priority than the viewer fundamentals in US-029/US-030. Medium complexity: requires a math-rendering library (e.g. KaTeX) integrated into the markdown pipeline with fallback handling.
