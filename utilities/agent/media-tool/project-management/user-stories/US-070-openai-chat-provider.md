---
id: US-070
title: "Generate via OpenAI chat"
slug: openai-chat-provider
personas: [P-001, P-002]
epic: "Chat Completion Integration"
priority: should-have
complexity: low
tags: [openai, chat-completion, gpt-4]
---

# US-070: Generate via OpenAI chat

## User Story

**As a** developer with an OpenAI subscription
**I want to** use GPT-4 for code and text generation
**So that** I can leverage OpenAI's capabilities alongside other providers

## Acceptance Criteria

- **Given** `service: openai-chat` and `OPENAI_API_KEY`
  **When** a chat completion request is made
  **Then** the OpenAI chat API is called with system + user messages

- **Given** `model: gpt-4o`
  **When** generation runs
  **Then** GPT-4o is used as the model

## Notes
OpenAI-compatible format. Same as z.ai but with different base URL and API key.
