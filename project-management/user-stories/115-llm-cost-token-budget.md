# US-115: LLM Cost and Token Budget Management

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P1
**Epic:** LLM & AI Systems

## Story
As Dave, I want complete visibility and control over LLM API spending so that I can run the game economically at scale — per-player token budgets prevent abuse, semantic caching cuts redundant calls, and I get alerted before spend runs away from me.

## Acceptance Criteria
- [ ] Per-player daily token budget enforced server-side: default budget configurable by account tier (free: 50k tokens/day, standard: 200k, premium: unlimited) with hard enforcement via ETS counter reset at UTC midnight
- [ ] Semantic caching layer stores recent LLM responses keyed by embedding similarity: requests with semantic similarity ≥ 0.95 to a cached query return the cached response without a provider call
- [ ] Request batching groups independent generation requests within a 100ms window before dispatch, reducing API call overhead for simultaneous multi-player room generation
- [ ] Cost dashboard in admin panel shows: total daily/monthly spend, spend per generation domain, spend per player tier, cache hit rate, token efficiency (content quality per token), top-10 most expensive players
- [ ] Alerting configured for: daily spend exceeding 80% of budget, per-hour spike exceeding 3x rolling average, individual player exhausting daily budget, cache hit rate dropping below 30%
- [ ] Token usage logged per request to `ai_usage_log` PostgreSQL table: `{player_id, domain, model, prompt_tokens, completion_tokens, cached, cost_usd, created_at}` — queryable for billing and analysis
- [ ] Player-facing budget status accessible via SETTINGS command: "AI narrative budget: 45,000 of 200,000 tokens used today." — not surfaced unless player is near limit (>80% used)
- [ ] Budget exhaustion handled gracefully: player notified via ARIA status message, AI generation falls back to template responses (US-102) for remainder of day, no gameplay blocking

## Notes
Per-player token budget implemented as an ETS counter per `player_id`, reset by a daily scheduled Oban job (`BladeOfEternity.Workers.TokenBudgetReset`) at UTC midnight. Budget check before every LLM dispatch: `TokenBudgetManager.check_and_reserve(player_id, estimated_tokens)` — returns `:ok` or `{:error, :budget_exhausted}`. Estimated token count uses a fast heuristic (character count / 4) before the actual call; actual count reconciled after response.

Semantic caching: `BladeOfEternity.AI.SemanticCache` — wraps LLM client. On request: embed the prompt context (using a lightweight local embedding model or a fast embedding API call), query pgvector index in PostgreSQL for nearest neighbors within similarity 0.95. Cache hit returns stored completion. Cache miss dispatches to LLM and stores result with embedding. Cache TTL: 1 hour for room descriptions (change with world state), 24 hours for item descriptions (rarely change), 30 minutes for combat narration.

Request batching: `BladeOfEternity.AI.RequestBatcher` — GenServer that accumulates requests per generation domain over a 100ms collection window, then dispatches as a structured batch (provider-specific batch API if available, else parallel Task.async_stream). Batching domain: room generation, item description generation, ambient narration. Not batched: combat narration (latency-sensitive), dialogue (per-player state required).

Cost calculation: `cost_usd = (prompt_tokens * prompt_price_per_1k / 1000) + (completion_tokens * completion_price_per_1k / 1000)`. Model prices stored in application config (updated manually on price changes). `ai_usage_log` entries aggregate daily by domain for dashboard queries (partitioned by day for query performance).

Alerting via Telemetry → Prometheus → Alertmanager pipeline. Alert rules defined in Prometheus config (managed in k8 infra repo). Admin panel also shows live spend widgets via Phoenix LiveView polling `ai_usage_log` aggregates every 60 seconds.

Cache hit rate optimization: semantic cache effectiveness depends on consistent context assembly. Using canonical player_id-stable room descriptions (same room at same world-state always generates same context hash) maximizes cache hits. World-state change events (weather change, NPC arrival/departure) invalidate room description cache entries for affected rooms via explicit cache eviction.
