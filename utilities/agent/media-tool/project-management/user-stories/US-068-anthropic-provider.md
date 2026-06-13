---
id: US-068
title: "Generate via Anthropic Claude"
slug: anthropic-provider
personas: [P-002, P-005]
epic: "Chat Completion Integration"
priority: must-have
complexity: medium
tags: [anthropic, claude, chat-completion, provider]
---

# US-068: Generate via Anthropic Claude

## User Story

**As a** developer generating code and complex diagrams
**I want to** use Claude models via the Anthropic API
**So that** I get the highest quality code and diagram generation

## Acceptance Criteria

- **Given** `service: anthropic` and `ANTHROPIC_API_KEY`
  **When** a chat completion request is made
  **Then** the Anthropic Messages API is called with system + user messages

- **Given** attachments in the prompt
  **When** the Anthropic provider is used
  **Then** attachments are sent as vision content blocks

## Notes
Anthropic supports vision input (attachments as images). Uses `x-api-key` header and `anthropic-version: 2023-06-01`.
