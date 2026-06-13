---
id: US-069
title: "Generate via Gemini chat"
slug: gemini-chat-provider
personas: [P-001, P-002]
epic: "Chat Completion Integration"
priority: must-have
complexity: medium
tags: [gemini, chat-completion, provider, google]
---

# US-069: Generate via Gemini chat

## User Story

**As a** developer already using Gemini for images
**I want to** use the same API key for text generation via `gemini-chat`
**So that** I get fast, cost-effective code and diagram generation

## Acceptance Criteria

- **Given** `service: gemini-chat` and `GEMINI_API_KEY`
  **When** a chat completion request is made
  **Then** the Gemini generateContent API is called with systemInstruction

- **Given** `model: gemini-2.5-flash`
  **When** generation runs
  **Then** the flash model is used for fast, cheap generation

## Notes
Shares `GEMINI_API_KEY` with the image provider. Distinguished by `service: gemini` vs `service: gemini-chat`.
