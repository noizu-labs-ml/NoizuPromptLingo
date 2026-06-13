---
id: US-022
title: "Code Blocks with Syntax Highlighting"
slug: "code-blocks-syntax-highlighting"
personas: [P-001, P-003, P-005]
epic: "Content Formatting"
priority: "should-have"
complexity: "M"
tags: [formatting, code, syntax-highlighting, readability]
---

# US-022: Code Blocks with Syntax Highlighting

## User Story

**As an** Indie Developer (P-005),
**I want to** include fenced code blocks with syntax highlighting in my prompt body and description,
**So that** code-heavy prompts (Python scripts, SQL queries, JSON schemas) are readable and professional-looking.

## Acceptance Criteria

- [ ] Given I write a fenced code block with a language identifier (e.g., ` ```python `) in the prompt body or description, when the content is rendered, then the code is displayed with syntax highlighting appropriate to the specified language.
- [ ] Given a code block is rendered, when I hover over or tap it, then a "Copy" button appears in the top-right corner; clicking it copies the raw code content (without highlighting markup) to the clipboard.
- [ ] Given I write a fenced code block without a language identifier (` ``` ` with no language), when the content is rendered, then the block is displayed in a monospace font without language-specific highlighting but with the copy button present.
- [ ] Given the syntax highlighter encounters an unrecognized language identifier, when the block is rendered, then it falls back to plain monospace display without throwing an error.
- [ ] Given I am viewing a prompt on a dark system theme, when code blocks are rendered, then they use a dark-compatible highlight theme (e.g., GitHub Dark or Dracula) that maintains sufficient contrast ratios per WCAG 2.1 AA.

## Notes

A client-side syntax highlighter (Prism.js or highlight.js) is recommended; both support 100+ languages covering the most common prompt use cases. The theme switching in AC-5 requires the app to respect the user's OS color scheme preference via `prefers-color-scheme`. Depends on US-021 for the Markdown rendering pipeline.
