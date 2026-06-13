---
id: ADR-003
title: "Multi-Agent Ensemble vs. Monolithic Memory Service"
status: accepted
date: 2026-05-27
---

# ADR-003: Multi-Agent Ensemble vs. Monolithic Memory Service

## Context

The memory service has a complex lifecycle with fundamentally competing concerns:

- **Store everything vs. guard integrity.** The Archivist wants to capture every potentially useful observation. The Guardian wants to reject anything that contradicts existing knowledge or looks like injection.
- **Link everything vs. keep focus.** The Weaver wants dense association graphs. The Curator wants to prune stale links to keep recall fast and focused.
- **Conserve memories vs. clean house.** The Curator wants to archive aggressively to manage storage. The Dreamer wants decaying memories kept alive long enough to find consolidation patterns.
- **Recall deeply vs. respond fast.** Active Recall wants exhaustive multi-hop traversal. Tangential Insertion needs sub-100ms responses.
- **Share openly vs. compartmentalize.** The Recall Agent wants maximum recall coverage. The Sentinel enforces access boundaries.

These tensions are not bugs — they are the mechanism by which the system produces emergent, balanced behavior. A monolithic service would resolve these tensions in if-else branches written by a developer. An agent ensemble resolves them dynamically through inter-agent negotiation on the event bus.

## Decision

Implement **8 specialized agents** communicating via a typed event bus:

| Agent | Responsibility | Biological Analogue |
|-------|---------------|---------------------|
| **Monitor** | Emotional state tracking, environmental context | Sensory nervous system |
| **Archivist** | Memory formation, enrichment, storage | Sensory cortex |
| **Guardian** | Integrity validation, contradiction detection, quarantine | Immune system |
| **Weaver** | Association building, edge weight management | Hippocampus |
| **Curator** | Lifecycle management, decay, pruning, archival | Prefrontal cortex |
| **Dreamer** | Background synthesis, consolidation, novel associations | Default mode network |
| **Sentinel** | Access control, compartmentalization, redaction | Blood-brain barrier |
| **Recall Agent** | Multi-path retrieval, ranking, winnowing, context injection | Conscious recall |

### Key Design Properties

1. **Each agent has a narrow, well-defined interface** — a `process(event: AgentEvent): AgentAction[]` method that consumes typed events and emits typed actions.
2. **Tensions are explicit** — the Guardian and Archivist are in designed tension. The Curator and Dreamer are in designed tension. This is documented and intentional.
3. **Communication is asynchronous** — agents communicate via an event bus, not direct method calls. This allows agents to be developed, tested, and tuned independently.
4. **Each agent has its own emotional disposition** — the Guardian is inherently cautious (high cortisol baseline), the Dreamer is inherently speculative (high dopamine baseline). These dispositions affect their decision thresholds.
5. **Agents are stateful** — each maintains its own state (e.g., the Monitor's current emotional vector, the Guardian's recent alert history, the Curator's storage metrics).

### Event Bus Architecture

Events are typed, schema-validated with Zod, and processed in guaranteed order within each agent's subscription. The bus provides at-least-once delivery with idempotency keys.

## Alternatives Considered

### Single Monolithic Service with Modules
- **Pros:** Simpler to deploy and debug. No inter-process communication overhead. Easier to reason about ordering. All logic in one process.
- **Cons:** Tensions resolved by static code rather than dynamic interaction. Hard to tune one concern without affecting others (e.g., tightening validation also slows formation). No natural model for the "Dreamer" — background synthesis becomes a cron job bolted onto the side. Testing requires mocking the entire system rather than testing agents in isolation.

### Microservice Per Function (Separate Processes)
- **Pros:** True process isolation, independent scaling, independent deployment. Could use different languages per agent.
- **Cons:** Massive operational overhead for 8 services. Network latency on every inter-agent call. Distributed transaction complexity for the formation pipeline (Archivist -> Guardian -> Archivist -> Weaver must be consistent). Overkill — the agents share a single data store and don't need independent scaling at the expected load.

### Three-Agent Simplified Model (Store / Recall / Maintain)
- **Pros:** Simpler. Three agents cover the core CRUD: Store handles formation + validation, Recall handles retrieval, Maintain handles lifecycle + synthesis.
- **Cons:** Loses the generative tension between Guardian and Archivist (both collapsed into "Store"). Loses the tension between Curator and Dreamer (both collapsed into "Maintain"). The Monitor's emotional tracking gets absorbed into Store as a preprocessing step, losing the clean separation between observation and formation. Essentially a microservice architecture with fewer services — the conceptual model collapses.

## Consequences

- **Positive:** Emergent behavior from agent tensions — the system self-balances between thoroughness and speed, conservation and cleanup, openness and security. Each agent can be independently developed, tested, and tuned. The biological metaphors provide intuitive mental models for operators. New agents can be added (e.g., a "Librarian" for search optimization) without restructuring existing ones.
- **Negative:** 8 agents is 8x the code surface. Inter-agent communication adds latency to the formation pipeline (event bus overhead). Debugging multi-agent interactions is harder than stepping through a single process. Potential for emergent failure modes (e.g., Guardian and Archivist deadlocking in mutual rejection).
- **Risks:** Agent orchestration complexity may delay initial delivery. The event bus becomes a single point of failure. If agent tensions are poorly calibrated (e.g., Guardian too strict), the system may exhibit pathological behavior that is hard to diagnose because the cause is distributed across agent interactions.

## Related

- ADR-004: Dual Retrieval Modes — the Recall Agent implements both active and tangential paths
- ADR-005: Hebbian-Like Weight Dynamics — the Weaver implements the association weight model
- ADR-007: TypeScript as Primary Language — all agents implemented in TypeScript
