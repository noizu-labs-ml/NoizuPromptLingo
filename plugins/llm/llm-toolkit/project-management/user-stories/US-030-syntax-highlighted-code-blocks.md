---
id: US-030
title: "Syntax-highlighted code blocks"
slug: syntax-highlighted-code-blocks
personas: [P-001, P-002]
epic: "Thread Viewer"
priority: must-have
complexity: low
tags: [viewer, code]
---

# US-030: Syntax-Highlighted Code Blocks

## User Story

**As a** staff engineer curating team knowledge
**I want to** see code blocks in thread messages syntax-highlighted by their declared or detected language
**So that** I can quickly scan and understand code snippets when reviewing a debugging session before turning it into a runbook

## Acceptance Criteria

- **Given** a message contains a fenced code block declared with a language (e.g. ```` ```elixir ````)
  **When** the thread viewer renders it
  **Then** the code is syntax-highlighted using that declared language's grammar

- **Given** a fenced code block has no declared language
  **When** rendered
  **Then** the viewer attempts language auto-detection and highlights accordingly, falling back to plain monospace if detection is inconclusive

- **Given** a code block is very long (100+ lines)
  **When** rendered
  **Then** it displays with a scrollable/contained region rather than forcing the whole page to a huge height, and highlighting still applies to the full block

## Notes
Priya relies on quickly scanning highlighted code while curating messy debugging sessions into clean runbooks/agents via the Convert wizard — unhighlighted code slows that triage significantly. Low complexity: standard syntax-highlighter integration (e.g. Shiki/Prism-class library) into the markdown renderer from US-029.
