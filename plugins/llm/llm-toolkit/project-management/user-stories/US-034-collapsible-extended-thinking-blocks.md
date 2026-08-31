---
id: US-034
title: "Collapsible extended-thinking blocks"
slug: collapsible-extended-thinking-blocks
personas: [P-002, P-004]
epic: "Thread Viewer"
priority: should-have
complexity: medium
tags: [viewer, thinking-blocks]
---

# US-034: Collapsible Extended-Thinking Blocks

## User Story

**As a** skill-authoring developer advocate
**I want to** see extended-thinking content in a visually distinct, collapsed-by-default block that I can expand to inspect the model's reasoning
**So that** I can study how the model arrived at a good pattern when deciding what to package into a reusable agent or skill

## Acceptance Criteria

- **Given** a message contains extended-thinking content
  **When** the thread viewer renders it
  **Then** it displays in a visually distinct style (e.g. a muted/italicized panel with a "thinking" label) separate from the regular response text, and defaults to collapsed

- **Given** a collapsed extended-thinking block
  **When** I click to expand it
  **Then** the full reasoning content renders, styled distinctly from the final response so it's clearly not the assistant's answer

- **Given** a message has no extended-thinking content
  **When** rendered
  **Then** no empty thinking block placeholder appears

## Notes
Tobias reviews reasoning traces when deciding whether a pattern in a debugging session is genuinely reusable enough to convert into a skill; Priya uses it similarly when curating team knowledge to understand why an approach was chosen, not just what was done. Should-have alongside tool-call collapsing (US-033) as part of the core scannable-thread experience.
