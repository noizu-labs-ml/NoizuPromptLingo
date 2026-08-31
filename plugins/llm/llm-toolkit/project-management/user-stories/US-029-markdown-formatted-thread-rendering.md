---
id: US-029
title: "Markdown-formatted thread rendering"
slug: markdown-formatted-thread-rendering
personas: [P-001, P-007]
epic: "Thread Viewer"
priority: must-have
complexity: medium
tags: [viewer, markdown]
---

# US-029: Markdown-Formatted Thread Rendering

## User Story

**As a** novice occasional user
**I want to** see message content rendered as formatted markdown — headings, lists, links, tables — instead of raw text with literal `#` and `*` characters
**So that** conversations are readable and I can follow the structure of a long explanation without parsing markdown syntax myself

## Acceptance Criteria

- **Given** a message contains markdown headings, bullet lists, and a table
  **When** the thread viewer renders it
  **Then** headings render at appropriate sizes, bullets render as a list, and the table renders as an actual HTML table with visible borders/rows

- **Given** a message contains a hyperlink in markdown syntax
  **When** rendered
  **Then** it displays as clickable link text (not the raw `[text](url)` syntax) and opens in a new tab

- **Given** a message contains raw/malformed markdown (e.g. an unclosed code fence)
  **When** rendered
  **Then** the viewer degrades gracefully — showing the content as plain text for the malformed section — rather than breaking the rest of the thread's rendering

- **Given** Marcus is scanning a long technical response for a specific command
  **When** the thread renders with proper heading/list structure
  **Then** he can visually scan structure instead of reading unformatted text top to bottom

## Notes
This is foundational to the entire Thread Viewer epic — syntax highlighting (US-030), Mermaid (US-031), and LaTeX (US-032) all render inside this markdown pipeline. Jamie's comfort with the tool depends heavily on this being polished since it's the primary way they read AI responses.
