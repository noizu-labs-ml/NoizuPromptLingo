---
id: US-021
title: "Markdown Support in Prompt Descriptions"
slug: "markdown-support"
personas: [P-001, P-003, P-006]
epic: "Content Formatting"
priority: "must-have"
complexity: "S"
tags: [formatting, markdown, description, rendering]
---

# US-021: Markdown Support in Prompt Descriptions

## User Story

**As a** Prompt Engineer (P-001),
**I want to** write my prompt description using Markdown syntax,
**So that** I can structure explanations with headers, lists, bold text, and inline code to make them easy to read.

## Acceptance Criteria

- [ ] Given I am writing in the description field, when I use Markdown syntax (# headers, **bold**, *italic*, - lists, `inline code`, > blockquotes, [links](url)), then toggling preview mode renders each element correctly according to CommonMark specification.
- [ ] Given I write a Markdown link in my description, when the prompt is rendered on the detail page, then all external links open in a new tab with `rel="noopener noreferrer"` and are sanitized to prevent javascript: URI injection.
- [ ] Given a description contains raw HTML tags, when the content is rendered, then all HTML is stripped and displayed as literal text — only Markdown-derived HTML is permitted.
- [ ] Given I am on mobile and viewing a rendered description, when the screen width is under 640px, then tables render with horizontal scroll rather than overflowing the page container.
- [ ] Given I am writing in the description editor, when I select text and press Ctrl+B (or Cmd+B on macOS), then the selected text is wrapped in `**` bold Markdown syntax.

## Notes

A CommonMark-compliant renderer (e.g., marked.js or remark) should be used with a strict HTML sanitizer (DOMPurify) applied after rendering. Keyboard shortcuts in AC-5 are a quality-of-life enhancement — the core requirement is rendering fidelity. This is a foundational dependency for US-014, US-025.
