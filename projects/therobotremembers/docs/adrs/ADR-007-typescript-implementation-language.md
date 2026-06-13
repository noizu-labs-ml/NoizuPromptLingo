---
id: ADR-007
title: "TypeScript as Primary Implementation Language"
status: accepted
date: 2026-05-27
---

# ADR-007: TypeScript as Primary Implementation Language

## Context

The Robot Remembers is an LLM-integrated agent memory service. Language choice affects:

1. **LLM SDK availability** — Agents call LLMs for emotional assessment, content summarization, contradiction detection, and consolidation. The language needs mature SDKs for OpenAI, Anthropic, and potentially local models.
2. **Development velocity** — The system is in active design; rapid iteration on agent behaviors and weight dynamics is essential.
3. **Schema validation** — Typed event bus messages, API request/response bodies, and configuration all benefit from runtime schema validation.
4. **Ecosystem breadth** — Vector DB clients (Weaviate), database drivers (pg), cache clients (ioredis), HTTP frameworks, and testing tools must all be available.
5. **Deployment target** — Kubernetes (see parent repo `infra/k8`). Container images should be small and fast to start.
6. **Team familiarity** — Keith's primary stack is Elixir. TypeScript is the secondary stack, used across the incubator portfolio (Next.js frontend, various API services).

## Decision

**TypeScript** for all backend services, with:

- **Zod** for runtime schema validation of events, API payloads, and configuration.
- **Turborepo** for monorepo workspace management.
- **Hono or Fastify** for the REST API framework.
- **Node 22+** runtime (native ES modules, stable `fetch`, `structuredClone`, `crypto.randomUUID`).

### Why Not Elixir (the Other Strong Candidate)

Elixir would arguably be the better technical choice for this specific system:

- **OTP supervision trees** are the natural model for agent lifecycle management — restart strategies, health monitoring, graceful degradation.
- **GenServer + Registry** is a battle-tested pattern for stateful agents with message-passing interfaces.
- **Lightweight processes (BEAM)** handle the concurrent agent model naturally — 8 agents as 8 processes with mailboxes, no async/await complexity.
- **Phoenix PubSub** is the event bus for free.
- **The existing Noizu framework** (Keith's own Elixir libraries) provides entity persistence, service pools, and GenAI integration.

However, TypeScript is chosen because:

1. **LLM SDK maturity.** The Anthropic and OpenAI TypeScript SDKs are first-class, with streaming, tool use, and structured output support. The Elixir equivalents exist but are community-maintained and lag behind.
2. **Incubator ecosystem alignment.** All other portfolio projects use TypeScript for backend services. Shared patterns, shared debugging, shared Docker base images.
3. **Hiring and contribution surface.** TypeScript developers are 10x more available than Elixir developers for potential contributors or future team members.
4. **Weaviate client.** The official Weaviate TypeScript client (`weaviate-ts-client`) is first-class. The Elixir client is community-maintained.

This is a pragmatic choice, not a technical one. The ADR explicitly acknowledges that Elixir's concurrency model is superior for agent orchestration.

## Alternatives Considered

### Elixir / Phoenix
- **Pros:** Superior concurrency model for agents (OTP/GenServer). Keith's primary language. Existing Noizu framework for entity persistence and GenAI. Phoenix PubSub for event bus. Excellent reliability and fault tolerance via supervision trees. Hot code reloading for agent behavior tuning.
- **Cons:** LLM SDK ecosystem lags TypeScript by 6-12 months. Smaller contributor pool. Weaviate client is community-maintained. Does not align with incubator portfolio stack (all other projects are TypeScript/Next.js). Docker images are larger (Erlang runtime).

### Python
- **Pros:** Dominant ML/AI ecosystem. Best LLM SDK support (langchain, llamaindex, anthropic, openai all Python-first). NumPy/SciPy for emotional vector math. Strong Weaviate client.
- **Cons:** No type safety without MyPy (which is opt-in and incomplete). GIL limits true concurrency for agent model. Package management is notoriously painful (pip, poetry, conda, uv — pick your adventure). Keith does not use Python as a primary language. Runtime performance requires careful optimization for the hot-path retrieval.

### Rust
- **Pros:** Maximum performance. Memory safety. Excellent for the hot-path retrieval pipeline. Small container images.
- **Cons:** Development velocity is 3-5x slower than TypeScript for this kind of iterative, behavior-heavy code. LLM SDK ecosystem is immature. Compile times slow iteration. The agents' behavior is LLM-prompt-driven, not compute-bound — Rust's performance advantage is wasted on "call LLM, wait for response, update database" workflows.

## Consequences

- **Positive:** Rapid iteration on agent behaviors. Mature LLM SDK ecosystem. Zod provides runtime type safety for the event bus and API surface. Aligns with incubator portfolio for shared patterns and tooling. Large talent pool for future contributors.
- **Negative:** The async/await concurrency model is inferior to BEAM processes for agent orchestration. No supervision trees — must build agent lifecycle management manually. Single-threaded event loop requires careful worker thread management for CPU-bound tasks (embedding computation, emotional vector math). Memory management is less predictable than Rust or Go.
- **Risks:** If the agent orchestration complexity grows beyond what async/await handles cleanly (e.g., complex inter-agent negotiation with timeouts and retries), the lack of OTP supervision trees may become painful. Mitigation: consider extracting the agent runtime into an Elixir service in a future phase, with TypeScript remaining for the API and storage layers. The package boundaries are designed to make this possible.

## Related

- ADR-003: Multi-Agent Ensemble — agents implemented as TypeScript classes with event bus subscriptions
- ADR-001: Three-Layer Storage Architecture — all three store clients are TypeScript packages
- ADR-006: Graph Storage in PostgreSQL — recursive CTE queries generated by the TypeScript `storage` package
