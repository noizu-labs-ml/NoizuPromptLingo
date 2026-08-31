---
id: US-076
title: "CLI show command"
slug: cli-show-command
personas: [P-001]
epic: "CLI (Ink)"
priority: must-have
complexity: low
tags: [cli, viewer]
---

# US-076: CLI Show Command

## User Story

**As a** solo power-user developer
**I want to** run `llm-toolkit show <id>` and have it print the given conversation to the terminal with markdown and code formatting preserved
**So that** I can review a session's content without leaving the terminal or opening the web UI

## Acceptance Criteria

- **Given** a valid conversation id
  **When** I run `llm-toolkit show <id>`
  **Then** the conversation is printed to stdout with markdown rendered (headers, lists, bold/italic) and code blocks syntax-highlighted per their declared language

- **Given** an id that doesn't exist in the index
  **When** I run `llm-toolkit show <bad-id>`
  **Then** the command exits with a non-zero status and a clear "conversation not found" error, not a stack trace

- **Given** a conversation containing collapsed-by-default tool-call/tool-result blocks in the web UI
  **When** I show it via CLI
  **Then** tool-call/tool-result content is rendered inline (or behind a `--full` flag if truncated by default) rather than silently omitted

- **Given** the terminal output is piped to another command (e.g. `| less`)
  **When** I run `llm-toolkit show <id> | less`
  **Then** output degrades gracefully to plain formatted text without relying on interactive/raw terminal control sequences that break in a pager

## Notes
Marcus lives in the CLI (`recent`, `search`, `show`) and reaches for `show` constantly when recalling exact prior context for a client repo without breaking flow to open the browser.
