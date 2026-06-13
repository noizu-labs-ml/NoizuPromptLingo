# US-119: LLM Model Switching and A/B Testing

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P2
**Epic:** LLM & AI Systems

## Story
As Dave, I want to run different LLM models for different generation domains and A/B test model quality so that I can make data-driven decisions about which models deliver the best narrative quality per dollar — without requiring a code deploy to switch models or adjust traffic splits.

## Acceptance Criteria
- [ ] Model routing table configurable per generation domain at runtime: specifies `{domain, variant}` → `{provider, model_id, temperature, max_tokens}` — changeable via admin panel without restart
- [ ] A/B traffic splitting supports up to 4 model variants per domain with configurable weight percentages; variant assignment is player-stable (same player consistently uses same model within experiment window)
- [ ] Model performance comparison dashboard shows per-variant metrics: latency percentiles (p50/p95/p99), token efficiency (completion tokens / content quality score), cost per request, quality score distribution (from US-125 human ratings and automated scores)
- [ ] Experiment lifecycle management: experiments have defined start/end dates, can be paused/resumed, and have a "winner promotion" action that sets the winning variant as 100% traffic with one click
- [ ] Player feedback collection integrated with A/B experiments: players can rate narrative descriptions (thumbs up/down via keyboard shortcut) — ratings attributed to the model variant that generated the content
- [ ] Provider failover in routing table: each domain can specify a primary and fallback provider; failover triggers automatically when primary circuit opens (US-102)
- [ ] Model routing decisions logged alongside LLM calls in `ai_usage_log`: `{domain, variant_id, model_id, provider}` — enables post-hoc analysis of which model generated specific content
- [ ] New model onboarding checklist: test suite of 50 standardized prompts per domain, automated quality scoring, latency benchmarks, cost calculation — must pass before model is eligible for production A/B testing

## Notes
Model routing implemented as `BladeOfEternity.AI.ModelRouter` — GenServer holding ETS table `:model_routes`. On request: `ModelRouter.route(domain, player_id)` returns a `ModelConfig` struct `{provider, model_id, temperature, max_tokens, variant_id}`. Routing reads from ETS (nanosecond access), no DB call on hot path.

ETS table populated from `model_routing_config` PostgreSQL table at startup and on admin-triggered reload. Config schema: `{id, domain, variant_id, provider, model_id, temperature, max_tokens, traffic_weight, experiment_id, active}`. Multiple rows per domain sum to 100% weight.

Player-stable variant assignment: same hash function as template registry A/B (US-107) — `{domain, player_id}` hashed with `:erlang.phash2/2`, modulo against cumulative weight boundaries. Within an experiment window (defined by `experiment_id`), same player always routes to same variant. Window change (new experiment) may reassign players.

`genai` Elixir library provider abstraction: `BladeOfEternity.AI.Providers` wraps `genai` with provider-specific adapters for Anthropic, OpenAI, Google Gemini. Each adapter implements `call/2` with a normalized `{prompt, model_config}` interface. Provider switching is a config change, not a code change.

Feedback collection: keyboard shortcut `Alt+U` (thumbs up) / `Alt+D` (thumbs down) on focused narrative text. Frontend sends `{feedback_type, content_hash}` to Phoenix Channel. Backend looks up `ai_generation_log` by content hash, retrieves variant_id, writes to `ai_feedback` table: `{player_id, content_hash, domain, variant_id, rating, created_at}`.

Quality score computation for dashboard: `avg(rating) WHERE variant_id = X AND domain = Y AND created_at > 7_days_ago`. Combined with automated voice consistency score (US-110) to produce a composite quality score per variant. Dashboard at `/admin/ai/experiments`.

New model onboarding: standardized test prompt library in `priv/ai/model_tests/*.yaml` — 50 prompts per domain with reference outputs (authored by narrative team). New model runs against all test prompts; automated scoring via voice consistency classifier (US-110) and embedding similarity to reference outputs. Results in onboarding report requiring human sign-off before production eligibility.

Provider failover: `ModelRouter` subscribes to circuit breaker events (US-102). When `{:circuit_opened, provider}` received, router switches all active experiments using that provider to their fallback provider (stored in routing config). When `{:circuit_closed, provider}` received, router restores original routing. Failover logged with timestamp and duration.
