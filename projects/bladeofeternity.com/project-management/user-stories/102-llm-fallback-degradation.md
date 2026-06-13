# US-102: LLM Fallback and Graceful Degradation

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P0
**Epic:** LLM & AI Systems

## Story
As Dave, I want the game to degrade gracefully when the LLM provider is slow or unavailable so that players never see a broken experience — they receive template-based fallback content while requests queue for retry, and screen reader users are informed via a dedicated status channel without interrupting gameplay.

## Acceptance Criteria
- [ ] LLM client implements circuit breaker pattern: after 3 consecutive failures or P95 latency exceeding 8 seconds, circuit opens and all requests route to fallback pipeline for a configurable cool-down period (default 60 seconds)
- [ ] Fallback pipeline uses pre-rendered template responses indexed by room archetype, NPC type, combat action type, and item category — covering 100% of generation request types
- [ ] Failed or queued LLM requests are posted to a dedicated ARIA live region (`aria-live="polite"` status channel) as brief, non-interruptive status messages ("The world feels still for a moment...")
- [ ] Request queue implemented as bounded GenServer queue (max 50 pending per player) with TTL expiry (30 seconds); expired requests resolve to fallback content, never silently drop
- [ ] Half-open circuit breaker probes with 1 in 10 requests; successful probe triggers circuit close and flushes queue with LLM-generated responses replacing fallback content already delivered
- [ ] Admin dashboard shows circuit state (open/closed/half-open), queue depth per player shard, fallback hit rate, and MTTR per circuit open event
- [ ] Fallback content is semantically tagged in ARIA output so quality-assurance tooling can distinguish LLM versus fallback responses in session logs
- [ ] Integration tests verify circuit opens under simulated provider timeout, fallback content delivered within 200ms, and circuit recovery sequence

## Notes
Circuit breaker implemented using the `fuse` Elixir library wrapping the `BladeOfEternity.AI.LLMClient` GenServer. Separate fuse instances per generation domain allow partial degradation (e.g., room descriptions fall back while NPC dialogue still routes to LLM).

Fallback template library stored in ETS, loaded from `priv/ai/fallbacks/` at application start. Templates use EEx with assigns for entity names, room type, weather, time-of-day — producing plausible but generic content. Template selection uses a multi-level key: `{domain, archetype, tone}` falling back through progressively generic keys.

ARIA status channel is a dedicated `<div role="status" aria-live="polite" aria-atomic="false">` in the React shell, separate from the main narrative region. Phoenix PubSub pushes status events to the player's channel; frontend injects them without displacing current content. Status messages use evocative in-world language rather than technical errors: "The winds of fate hesitate..." rather than "LLM unavailable."

Queue implemented as `BladeOfEternity.AI.RequestQueue` — a GenServer per player shard holding a priority queue (combat > dialogue > ambient). Priority ensures combat narration always resolves first. Queue state logged to Telemetry for Prometheus scraping.

On circuit recovery, the queue flush replaces already-delivered fallback text only in the scroll buffer if the player hasn't scrolled past it (detected via client-side flag), otherwise new LLM content is injected as a continuation.
