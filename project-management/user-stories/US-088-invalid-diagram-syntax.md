---
id: US-088
title: "Handle invalid or unsupported diagram syntax gracefully"
slug: "invalid-diagram-syntax"
personas: [P-001, P-005, P-007]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "S"
tags: [error-handling, diagram, syntax, validation]
---

# US-088: Handle invalid or unsupported diagram syntax gracefully

## User Story

**As a** QA Engineer (P-007),
**I want to** receive a clear error when I provide invalid PlantUML, Mermaid, or SVG syntax,
**So that** I can identify and fix the syntax issue rather than waiting for a silent failure.

## Acceptance Criteria

- [ ] Given I submit a diagram prompt that produces invalid PlantUML syntax, when the rendering engine attempts to parse it, then a validation error is returned with the line number and description of the syntax error
- [ ] Given I submit a diagram type that is not supported by the selected renderer, when the request is processed, then the response indicates the unsupported type and lists the supported types
- [ ] Given a syntax error is returned, when the error is displayed in the UI, then the offending line or section is highlighted in the raw source view

## Notes

Validation should occur server-side using the respective renderer's parser (PlantUML CLI, Mermaid parser). Raw source view with syntax highlighting should be available on all diagram-type mockups regardless of error state. Related to US-084.
