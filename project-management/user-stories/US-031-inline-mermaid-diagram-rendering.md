---
id: US-031
title: "Inline Mermaid diagram rendering"
slug: inline-mermaid-diagram-rendering
personas: [P-002, P-004]
epic: "Thread Viewer"
priority: should-have
complexity: medium
tags: [viewer, mermaid]
---

# US-031: Inline Mermaid Diagram Rendering

## User Story

**As a** skill-authoring developer advocate
**I want to** have Mermaid code fences in a message render as an interactive diagram inline in the thread viewer
**So that** I can review architecture/flow diagrams the assistant produced without copy-pasting the raw Mermaid source into an external renderer

## Acceptance Criteria

- **Given** a message contains a fenced code block with the `mermaid` language tag and valid diagram syntax
  **When** the thread viewer renders the message
  **Then** the diagram renders visually inline (flowchart, sequence diagram, etc.) in place of the raw text

- **Given** a Mermaid block contains invalid/malformed diagram syntax
  **When** rendering is attempted
  **Then** the viewer falls back to displaying the raw code block with a visible "diagram failed to render" indicator, rather than breaking the page

- **Given** a rendered diagram is large or complex
  **When** I interact with it
  **Then** I can pan/zoom or expand it to a larger view rather than being limited to the thread's inline width

## Notes
Priya uses this when reviewing an incident doc assembled via Merge that includes an architecture diagram from the original debugging thread; Tobias reviews diagrams the assistant generated while designing a skill/agent. Medium complexity — requires a Mermaid rendering library integration plus malformed-input handling.
