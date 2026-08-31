# 14: Settings

| Field | Value |
|-------|-------|
| ID | SCR-14 |
| Surface | web |
| Type | settings |
| Category | Onboarding / Core |
| Route / Entry | `/settings` |
| Primary Personas | P-008, P-001, P-005 |
| User Stories | US-016, US-017, US-018, US-019, US-020, US-006, US-011, US-012, US-039, US-081, US-086, US-098 |

## Description
Configuration for indexed paths, embedding provider, LLM provider (used for Simplify/Summarize/Convert-candidate operations), and display preferences. The only place provider credentials and reindex controls live.

## Entry Points
- Global nav "Settings"
- First-run wizard hand-off (US-002, US-006) lands here for advanced configuration

## Key Components
- IndexConfig → PathList (add/remove watched conversation directories), ReindexBtn (full / incremental, US-012)
- EmbeddingConfig — provider selector; LocalOption (Transformers.js + model selector), HostedOption (OpenAI/Voyage/Anthropic + API key)
- LLMConfig — provider for simplify/summarize operations, with per-operation override (US-019) and connectivity validation (US-020)
- DisplayConfig — theme (Nocturne only, for now; high-contrast / reduced-motion variant per US-039), code font, line numbers
- LocalOnlyStatement — explicit "fully local" privacy statement when no hosted provider is configured (US-016)

## States
- **Loading:** form fields populate from `GET /api/config`
- **Saving:** per-section save affordance with inline success/error feedback on `PATCH /api/config`
- **Error:** provider connectivity check (US-020) and any live LLM provider request failure (US-086) surface a clear, specific reason (auth, network, bad endpoint) rather than a generic error
- **Index health:** a locked/corrupted index (US-081) is surfaced here with remediation guidance rather than only failing silently elsewhere
- **Watcher status:** IndexConfig reflects the file watcher's idle resource footprint indirectly via its idle/running state — the watcher itself is designed to stay low-overhead at idle (US-098, background behavior with no dedicated control surface)

## Interactions
- Adding a path triggers a background index pass; ReindexBtn offers explicit full vs. incremental control
- Switching embedding provider warns that existing embeddings become stale and a reindex is required
- "Validate" button on LLM/embedding provider fields performs a lightweight connectivity check before save

## Navigation
- **From:** global nav, first-run flow
- **To:** n/a (terminal settings page)
