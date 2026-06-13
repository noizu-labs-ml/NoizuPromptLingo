---
id: US-047
title: "Track token usage and costs"
slug: "token-cost-tracking"
personas: [P-006, P-003]
epic: "Narrative Engine"
priority: "should-have"
complexity: "M"
tags: [narrative-engine, tokens, cost, observability, analytics]
---

# US-047: Track Token Usage and Costs

## User Story

**As a** game studio lead managing API spend across thousands of players (P-006),
**I want to** track prompt tokens, completion tokens, and estimated cost per LLM call and per session,
**So that** I can monitor spend in real time, set per-session budgets, and optimize prompts against measurable cost/quality trade-offs.

## Acceptance Criteria

- [ ] Given an LLM call that completes, when I call `engine.last_usage()`, then a `TokenUsage` object is returned with `prompt_tokens`, `completion_tokens`, `total_tokens`, and `estimated_cost_usd`.
- [ ] Given a model pricing config `{"gpt-4o": {"input": 0.005, "output": 0.015}}` registered via `engine.set_pricing(config)`, when cost is computed, then `estimated_cost_usd` reflects the configured per-1k-token rates.
- [ ] Given a session with 20 LLM calls, when I call `engine.session_usage()`, then cumulative `prompt_tokens`, `completion_tokens`, `total_tokens`, and `estimated_cost_usd` across all calls are returned.
- [ ] Given a per-session budget configured via `engine.set_session_budget(usd=1.00)`, when cumulative session cost exceeds that budget, then a `SessionBudgetExceededError` is raised on the next `engine.generate()` call before the LLM is invoked.
- [ ] Given an unknown model (no pricing config registered), when cost is computed, then `estimated_cost_usd=None` is returned and a `PricingUnknownWarning` is logged rather than an error.
- [ ] Given token usage data, when I call `engine.export_usage(format="csv")`, then a CSV string is returned with columns `call_id`, `timestamp`, `model`, `prompt_tokens`, `completion_tokens`, `cost_usd`.

## Notes

P-006 needs cost observability for budgeting; P-003 needs token counts for research reproducibility. This story should surface data that feeds into US-039 (context token budget) tuning decisions. Pricing configs should support both per-1k and per-1M token rate formats used by different providers.
