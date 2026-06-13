# Architecture Decision Records

## ADR-001: Python as Primary Language

**Status:** Accepted

**Context:** The framework needs a language that its target audience (indie game devs, ML/AI engineers, interactive fiction authors) already uses. The AI/ML ecosystem is overwhelmingly Python.

**Decision:** Python 3.11+ with full type annotations and Pydantic models. TypeScript SDK auto-generated post-v1.0.

**Consequences:** Locks out pure-JS game devs until the TypeScript SDK ships. Accepted because the Python ML community is the primary adoption vector.

## ADR-002: Independent Components Over Monolithic Framework

**Status:** Accepted

**Context:** Different games need different subsystems. A dungeon crawler needs combat + world state but not dialogue. A visual novel needs dialogue + memory but not quest engines.

**Decision:** Each of the six components is independently usable. No component requires any other component. Integration happens through typed `GameEvent` objects.

**Consequences:** More surface area to maintain. Components must define clean interfaces rather than sharing internal state. Worth it for adoption flexibility.

## ADR-003: Events as Ground Truth (LLM Doesn't Own State)

**Status:** Accepted

**Context:** LLMs hallucinate. If the LLM says "you found a legendary sword," that must be validated against world rules before it becomes real game state. Letting the LLM directly mutate state leads to inconsistencies.

**Decision:** LLMs produce prose + proposed state changes. The `EventParser` extracts typed `GameEvent` objects. The `Validator` checks them against world rules. Only validated events mutate state.

**Consequences:** More complex parsing pipeline. Potential for the LLM's narrative to diverge from validated state (the LLM says X happened, but validation rejected it). Requires a reconciliation strategy.

## ADR-004: Token-Budgeted Context Assembly

**Status:** Accepted

**Context:** RPGs accumulate unbounded state over time. Naive approaches (dump everything into the prompt) fail after ~20 interactions. General LLM frameworks don't solve this because it's an RPG-specific relevance problem.

**Decision:** The `ContextBuilder` assembles each LLM call from relevant state, prioritized by relevance, constrained by a configurable token budget. v0.1 uses recency-only; v0.2 adds semantic similarity.

**Consequences:** Context quality directly determines narrative quality. This is the technical moat. Requires extensive testing across different game scenarios and LLM providers.

## ADR-005: LLM-Agnostic via ModelProvider Interface

**Status:** Accepted

**Context:** The LLM landscape changes rapidly. Developers want to use GPT-4 in production, Ollama locally, and switch providers without rewriting game code.

**Decision:** All LLM calls go through a `ModelProvider` interface with built-in providers for OpenAI, Anthropic, and Ollama. Custom providers implement a simple async interface.

**Consequences:** Must maintain multiple provider implementations. Structured output quality varies by model (GPT-4 is great at JSON mode, smaller models struggle). Need per-provider output handling.

## ADR-006: Open-Source Core with Commercial Services

**Status:** Accepted

**Context:** Developer frameworks need to be free to gain adoption. Revenue comes from services that reduce operational burden.

**Decision:** MIT-licensed core framework. Revenue from Cloud Playground ($9/mo), Managed Memory ($19-49/mo), Managed Models ($29/mo), and Enterprise ($499+/mo). Additional revenue from component/template marketplaces.

**Consequences:** Must build enough value in the free tier to drive adoption while keeping commercial services compelling. The cloud services are a separate engineering effort from the framework itself.
