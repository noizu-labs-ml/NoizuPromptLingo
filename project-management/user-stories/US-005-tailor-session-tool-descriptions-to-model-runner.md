---
id: US-005
title: "Tailor a session's tool descriptions to the target model/runner"
slug: "tailor-session-tool-descriptions-to-model-runner"
personas: [P-002]
epic: "Work Sessions"
priority: "could-have"
complexity: "M"
tags: [sessions, mcp, tool-descriptions, tailoring]
---

# US-005: Tailor a session's tool descriptions to the target model/runner

## User Story

**As the** Autonomous Coding Agent (P-002) running inside a specific harness/model combination,
**I want to** request that a session's exposed MCP tool descriptions be tailored to my target model and runner,
**So that** the tool surface I receive matches my context-window budget and instruction-following quirks instead of a generic one-size-fits-all description set.

## Acceptance Criteria

- [ ] Given an active session and a declared model/runner identifier (e.g. "claude-code" vs "codex-cli"), when the agent requests tailored tool descriptions, then the returned tool definitions differ in verbosity/phrasing from the default set in a way traceable to that runner identifier.
- [ ] Given a session with no tailoring requested, when tools are listed, then the default, untailored descriptions are served, proving tailoring is opt-in and non-breaking.
- [ ] Given an unrecognized model/runner identifier, when tailoring is requested, then the session falls back to the default tool descriptions rather than failing the call outright.
- [ ] Given a session that already has tailored descriptions cached, when the same model/runner requests tools again, then the cached tailored set is served without recomputing from scratch.

## Notes

Mirrors a skill-level prompt-tailoring pattern applied instead at the session/tool-surface level; complexity is M because it requires per-runner description variants plus a resolution/fallback path.
