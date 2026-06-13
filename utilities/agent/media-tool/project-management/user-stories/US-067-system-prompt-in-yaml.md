---
id: US-067
title: "Use system prompt for chat completion providers"
slug: system-prompt-in-yaml
personas: [P-002, P-005]
epic: "Chat Completion Integration"
priority: must-have
complexity: low
tags: [system-prompt, chat, provider, yaml]
---

# US-067: Use system prompt for chat completion providers

## User Story

**As a** developer generating code and diagrams
**I want to** include a system prompt in the `.media.prompt` file
**So that** I can instruct the LLM on output format and constraints

## Acceptance Criteria

- **Given** a `prompt.system` field in the YAML
  **When** a chat completion provider is used
  **Then** the system prompt is sent as the system message in the API call

- **Given** no `prompt.system` field
  **When** a chat completion provider is used
  **Then** a default system prompt is used (or none, depending on provider)

## Notes
System prompts control output format. E.g., "Output ONLY valid Mermaid markup. No code fences."
