# Agent Design Principles

Research-backed principles for building effective AI agents. Every recommendation cites its source.

---

## Principle 1: Start Simple, Prove You Need Complexity

> "The most successful agent implementations use simple, composable patterns — not complex frameworks."
> — Anthropic, "Building Effective Agents" (2024-2025)

The single most agreed-upon principle across all major sources:

| Source | Quote/Finding |
|--------|--------------|
| Anthropic | "Only add complexity when evaluation shows the simpler approach fails" |
| OpenAI | "Start with a single agent, add tools. Only split when instructions contradict" |
| Academic | Survey of 90 studies: tool-augmented LLMs → single agents → multi-agent only as needed |

### The Complexity Tax

Each level on the Complexity Ladder introduces:
- **More failure modes** — infinite loops, context poisoning, deadlock
- **Higher cost** — every agent call costs money; multi-agent = multiplicative
- **Harder debugging** — single-step traces → distributed traces
- **Longer latency** — sequential agent calls are serial bottlenecks

### Decision Rule

Before climbing a level, answer: **"What specific failure of the simpler approach am I fixing?"** If you can't point to a concrete failure in evaluation, you don't need the complexity.

---

## Principle 2: Context Engineering Is the Core Competency

> "Context engineering is the delicate art and science of filling the context window with just the right information for the next step."
> — Andrej Karpathy, 2025

**Context engineering replaced prompt engineering in 2025.** The shift: it's not about writing better static prompts — it's about building systems that dynamically assemble the right information per inference call.

### The Seven Context Layers

Every agent inference call should consider which of these layers to include:

| Layer | Static/Dynamic | Strategy |
|-------|---------------|----------|
| 1. System instructions | Static | Version-controlled, tested, immutable |
| 2. Conversation history | Dynamic | Hierarchical summarization — older turns get progressively compressed |
| 3. Retrieved knowledge | Dynamic | Relevance-scored, size-bounded, freshness-weighted |
| 4. Persistent memory | Dynamic | Scoped by user/session/org, conflict-resolved |
| 5. Tool definitions | Dynamic | Lazy-loaded per task, not all at startup |
| 6. Task state | Dynamic | Scratchpad + intermediate results, periodically compacted |
| 7. Guardrail context | Static | Immutable prefix, highest precedence |

### Key Finding: Large Context != Good Retrieval

Models fail to attend to information in the middle of long contexts ("lost in the middle" phenomenon). This persists even with 1M+ token windows. **Large context windows help with availability but not reliable retrieval.**

Implication: Don't dump everything into context and hope the model finds it. Use retrieval strategies:
- Put critical information at the start and end of context
- Use hierarchical summarization for history
- Score retrieved content by relevance before including it
- Implement TTL-based cache invalidation for tool results

### Sources
- Karpathy on context engineering (2025)
- Gartner: "Context engineering will appear in 80% of AI tools by 2028" (July 2025)
- Mem0: "Context Engineering Guide for AI Agents" (2025)
- Atlan: "What is Context Engineering?" (2025)

---

## Principle 3: Design Tools for the Agent, Not for Humans

> "Tools are contracts between deterministic systems and non-deterministic agents."
> — Anthropic, "Writing Effective Tools for AI Agents" (2025)

Anthropic and OpenAI converge completely on this. Bad tool design is the #1 cause of agent failures that aren't prompt failures.

### The Six Tool Design Rules

| Rule | Bad Example | Good Example |
|------|-------------|-------------|
| **Format for the model** | Pretty-printed HTML table | JSON with typed fields |
| **Include examples** | `description: "Search the database"` | `description: "Search users. Example: search_users(query='email:*@gmail.com', limit=10) returns [{id, email, name}]"` |
| **Design for recoverability** | `Error: NullPointerException at line 42` | `Error: User not found. Try listing users first with list_users(limit=10) to find valid IDs.` |
| **Paginate everything** | Returns all 50,000 records | `limit` and `offset` parameters, default limit=20 |
| **High-leverage operations** | `read_file(path)` only | `search_codebase(query, file_pattern)` with semantic understanding |
| **Lazy loading** | Load all 100 tool schemas at startup | Tool Search tool discovers relevant tools on demand |

### Advanced: Programmatic Tool Calling (2025)

Let the model write code that calls tools in a sandbox. This reduces turn-taking round trips dramatically for multi-step tool workflows.

### Advanced: Tool Search Pattern (2025)

For agents with large tool catalogs (50+), don't load all schemas into context. Provide a `tool_search(query)` meta-tool that returns relevant tool schemas on demand.

### Sources
- Anthropic: "Writing Effective Tools for AI Agents" (2025)
- Anthropic: "Advanced Tool Use" (2025)
- OpenAI: "A Practical Guide to Building Agents" (2025)

---

## Principle 4: Guardrails Are Architectural, Not Afterthoughts

> "88% of organizations deploying AI agents reported at least one security incident in 2025."
> — Industry survey, 2025

> "Indirect instruction injection through retrieved content is now the dominant attack vector for agentic systems."
> — OWASP LLM Top 10, 2025-2026

### The Guardrail Sandwich

Production agents need checks at **every model boundary**:

```
User Input
  → [Pre-Input Guardrail] → validate, sanitize
    → Context Assembly
      → [Post-Retrieval Guardrail] → scan for injection in retrieved docs
        → Model Inference
          → [Pre-Tool-Call Guardrail] → validate tool name, params, authorization
            → Tool Execution
              → [Post-Output Guardrail] → content policy, format validation
                → User Output
```

### The Agent Control Plane

An emerging architectural pattern (2025-2026): governance infrastructure that sits **outside** the agent's execution loop, providing independent visibility and enforcement. Analogous to a service mesh in microservices.

Components:
- **Policy engine** — declarative rules for what agents can/can't do
- **Audit log** — every tool call, every decision, every output
- **Circuit breaker** — automatic halt when error rate exceeds threshold
- **Rate limiting** — prevent runaway cost from infinite loops

### The Dominant Threat: Indirect Prompt Injection

In agentic contexts, injection is far more dangerous than in simple chat. A successful injection doesn't just change one response — it can hijack the agent's goal and manipulate subsequent tool calls.

Three vectors (OWASP 2026 taxonomy):
1. **Direct goal manipulation** — user-facing injection
2. **Indirect instruction injection** — hidden in retrieved documents, RAG content, tool outputs
3. **Recursive hijacking** — goal modifications that propagate through reasoning chains

### Sources
- OWASP LLM Top 10 (2025, updated 2026)
- Agent-SafetyBench (2024-2025): 2,000 test cases across 10 failure modes
- Trantorinc: "AI Agent Failure Modes" (2025)
- Orq.ai: "LLM Guardrails Guide" (2025)

---

## Principle 5: Make Reasoning Visible

> "Agents that expose their assumptions, decisions, and state are debuggable. Agents that don't are black boxes that fail silently."

### Why Visibility Matters

- **Debugging** — when an agent makes a bad decision, you need to see why
- **Trust** — users trust agents more when they can see the reasoning
- **Evaluation** — you can't improve what you can't measure
- **Drift detection** — over long conversations, agents drift from their original objective; visible state makes drift detectable

### Visibility Techniques

| Technique | What It Reveals | Implementation |
|-----------|----------------|----------------|
| Intent declaration | Assumptions, scope, expected outcomes | NPL `<npl-intent>` or structured preamble |
| Chain-of-thought | Step-by-step reasoning | NPL `<npl-cot>` or `<thinking>` blocks |
| Decision logging | Which path was chosen and why | NPL `<npl-poa>` or structured decision records |
| Reflection | Post-hoc self-assessment | NPL `<npl-ref>` or explicit self-review step |
| State exposure | Current cognitive/emotional state | NPL `<npl-vos>` + hormones, or structured status |
| Thought bubbles | Organic observations during work | NPL `<npl-thought>` or inline annotations |

### The Reflexion Pattern (Academic, 2023-2025)

Agent reflects on task failures and stores lessons for retry:
1. Agent attempts task
2. Agent fails
3. Agent generates a reflection: what went wrong and why
4. Reflection is stored in memory
5. On retry, reflection is included in context
6. Agent avoids the same mistake

### LATS (Language Agent Tree Search)

Combines reflection with tree search over action sequences. Instead of linear retry, the agent explores multiple action paths simultaneously, evaluating each, and selecting the most promising. Higher cost, higher success rate on complex tasks.

### Sources
- Reflexion: Language Agents with Verbal Reinforcement Learning (Shinn et al., 2023)
- LATS: Language Agent Tree Search (Zhou et al., 2023)
- NPL@1.0 Intuition Pumps specification
