---
id: US-039
title: "Assemble context with token budget"
slug: "context-token-budget"
personas: [P-001, P-006]
epic: "Narrative Engine"
priority: "must-have"
complexity: "L"
tags: [narrative-engine, context, tokens, budget, llm]
---

# US-039: Assemble Context with Token Budget

## User Story

**As a** game studio lead managing API costs at scale (P-006),
**I want to** configure a maximum token budget for context assembly and have the Narrative Engine automatically prioritize, truncate, and summarize context sections to stay within that budget,
**So that** LLM calls never exceed token limits and prompt costs remain predictable across thousands of concurrent players.

## Acceptance Criteria

- [ ] Given a token budget of N, when I call `engine.assemble_context(budget=N)`, then the resulting context string contains fewer than N tokens as measured by the configured tokenizer.
- [ ] Given context sections with assigned priority weights (e.g. `player_state=1.0`, `world_state=0.8`, `history=0.5`), when the budget is insufficient for all sections, then lower-priority sections are truncated or dropped first.
- [ ] Given a context assembly that drops any section due to budget constraints, when the assembly completes, then a `ContextBudgetReport` is returned listing which sections were included, truncated, or dropped, and their token counts.
- [ ] Given a history section with 20 turns and a tight budget, when the engine truncates it, then the most recent turns are retained and older turns are dropped (recency bias).
- [ ] Given a budget of 0 or a negative value, when `assemble_context` is called, then a `ValueError` is raised immediately.
- [ ] Given a custom tokenizer function registered via `engine.set_tokenizer(fn)`, when token counting occurs, then `fn` is used instead of the default tiktoken-based counter.

## Notes

This is the most critical Narrative Engine story — all LLM calls flow through context assembly. P-006 needs deterministic cost control; P-001 needs flexibility during development. Depends on all World State Manager stories as context sources. Related to US-047 (token cost tracking).
