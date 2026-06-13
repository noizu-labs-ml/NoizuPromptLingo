---
id: US-021
title: "Refine a generated image interactively"
slug: interactive-refinement-loop
personas: [P-001, P-006]
epic: "Interactive Refinement"
priority: must-have
complexity: high
tags: [refine, interactive, feedback-loop]
---

# US-021: Refine a generated image interactively

## User Story

**As a** developer iterating on a key asset
**I want to** run `--refine` to enter a feedback loop
**So that** I can improve generated output through natural language feedback

## Acceptance Criteria

- **Given** a generated image and `--refine` mode
  **When** the image is displayed
  **Then** I'm prompted with "Satisfied? (y/n/feedback):"

- **Given** I provide feedback text
  **When** the refinement processes
  **Then** the prompt is rewritten using Gemini 2.0 Flash and the image is regenerated

- **Given** I answer "y"
  **When** the feedback loop is active
  **Then** the current output is accepted and the tool moves to the next prompt

## Notes
Refinement uses a text model to rewrite the prompt based on feedback. History is appended as YAML comments.
