---
id: US-003
title: "Generate SVG via LLM chat completion"
slug: generate-svg-via-llm
personas: [P-001, P-002]
epic: "Core Generation"
priority: must-have
complexity: medium
tags: [svg, text-output, chat-completion]
---

# US-003: Generate SVG via LLM chat completion

## User Story

**As a** developer needing vector graphics
**I want to** generate SVG files via a chat completion provider
**So that** I get scalable vector output that I can edit and embed directly

## Acceptance Criteria

- **Given** a `.media.prompt` with `service: gemini-chat`, `text_format: svg`
  **When** I run generation
  **Then** an `.svg` file is produced containing valid SVG markup

- **Given** the LLM returns code fences or explanation text
  **When** the output is processed
  **Then** only the SVG markup is extracted and saved (no code fences, no explanation)

## Notes
Text output requires stripping code fences and extracting the actual markup from LLM responses.
