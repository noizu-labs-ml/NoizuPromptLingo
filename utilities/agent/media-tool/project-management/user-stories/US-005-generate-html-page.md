---
id: US-005
title: "Generate an HTML page via chat completion"
slug: generate-html-page
personas: [P-001, P-008]
epic: "Core Generation"
priority: must-have
complexity: medium
tags: [html, text-output, chat-completion]
---

# US-005: Generate an HTML page via chat completion

## User Story

**As a** developer building landing pages
**I want to** generate a complete HTML page from a text description
**So that** I can quickly prototype web pages without writing boilerplate

## Acceptance Criteria

- **Given** a `.media.prompt` with `type: html`, `service: anthropic`
  **When** I run generation
  **Then** a complete `.html` file is produced with inline CSS and no external dependencies

- **Given** the prompt includes design token attachments
  **When** the HTML is generated
  **Then** the output uses the provided color, typography, and spacing values

## Notes
System prompt should enforce self-contained HTML with inline styles. No external JS/CSS dependencies.
