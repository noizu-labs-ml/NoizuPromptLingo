---
name: trl-agentic-harness-engineer
description: Design, implement, evaluate, and security-harden LLM agentic systems — from architecture through production deployment. Use this skill when the user wants to build an agentic harness, scaffold an AI agent system, design tool-use pipelines, implement guardrails, create eval suites for agents, red-team LLM applications, harden against prompt injection, build multi-agent coordination, implement agent memory systems, design agent routing, create agent observability, or deploy agentic systems to production — even if they don't say "harness." Also trigger when users mention agent loops, ReAct patterns, tool sandboxing, agent eval, OWASP LLM Top 10, agent orchestration, chain-of-thought steering, function calling pipelines, agent state machines, supervisor agents, or agentic security.
---

# Agentic Harness Engineer

Full-lifecycle skill for building production-grade LLM agentic systems. Covers architecture design, implementation scaffolding, evaluation pipelines, security hardening, observability, and deployment — with TypeScript as the primary stack and runnable code as the primary output.

## Overview

- **Architecture design** — Select and compose agentic patterns (ReAct, plan-and-execute, multi-agent, router) based on task requirements and constraint analysis
- **Implementation scaffolding** — Generate harness code: tool integration, state management, conversation handling, memory systems, and routing logic
- **Evaluation pipelines** — Build offline benchmarks and online monitoring: accuracy, safety, latency, cost, and regression testing
- **Security hardening** — Defend against prompt injection, tool misuse, data exfiltration, privilege escalation, and output poisoning using defense-in-depth
- **Observability** — Instrument agents with structured logging, distributed tracing, cost tracking, and anomaly detection
- **Deployment** — Production patterns for scaling, failover, rate limiting, and graceful degradation

## Core Philosophy

1. **Defense-in-depth by default** — Every generated harness includes input validation, output filtering, tool sandboxing, and audit logging. Security is not a phase; it's a property of every layer.
2. **Eval-driven development** — Write evals before implementing agent logic. Agent behavior is defined by what it measurably does, not what the prompt says it should do.
3. **Minimal viable agent** — Start with the simplest pattern that could work (single-turn tool use), prove it with evals, then add complexity (multi-turn, multi-agent) only when evals demand it.
4. **Observable by construction** — Every LLM call, tool invocation, and state transition emits structured telemetry. You can't improve what you can't measure.
5. **Fail-safe over fail-open** — When uncertain, agents refuse rather than hallucinate. When a tool call fails, agents surface the error rather than retrying silently. When guardrails trigger, the system halts and logs rather than attempting recovery.

## When to Use This Skill

- **Building a new agentic system** — Full lifecycle from architecture through deployment
- **Adding tool use to an existing LLM application** — Tool integration, sandboxing, error handling
- **Creating an eval suite for agents** — Benchmark design, dataset curation, scoring functions
- **Security-hardening an existing agent** — Threat modeling, injection defense, output filtering
- **Designing multi-agent coordination** — Router, supervisor, swarm, and debate patterns
- **Implementing agent memory** — Short-term (conversation), long-term (vector store), episodic (experience replay)
- **Debugging agent behavior** — Observability instrumentation, trace analysis, regression detection
- **Red-teaming an agentic system** — Adversarial testing, jailbreak probing, exfiltration attempts
- **Deploying agents to production** — Scaling, rate limiting, failover, cost control
- **Building agent UIs** — Chat interfaces, admin dashboards, tool approval workflows

> For MCP server design and implementation, see **trl-mcp-builder** / **trl-mcp-architect** / **trl-mcp-forge**.
> For Claude API specifics (caching, thinking, batch), see **claude-api**.
> For threat modeling methodology (STRIDE, PASTA), see **trl-threat-modeler**.
> For database design backing agent memory, see **trl-dba-db-designer-and-tuning**.
> For agent UI design and implementation, see **trl-user-experience-engineer**.

## Agentic Architecture Patterns

### Pattern Selection Matrix

| Pattern | When to Use | Complexity | Eval Difficulty |
|---------|-------------|-----------|-----------------|
| **Single-turn tool use** | Deterministic tasks, API wrappers | Low | Low |
| **ReAct loop** | Open-ended reasoning with tools | Medium | Medium |
| **Plan-and-execute** | Multi-step tasks with known structure | Medium | Medium |
| **Router** | Heterogeneous request types | Medium | Low per route |
| **Supervisor** | Sub-agent coordination with oversight | High | High |
| **Swarm** | Parallel independent sub-tasks | High | Medium |
| **Debate/critique** | High-stakes decisions needing verification | High | High |
| **State machine** | Compliance-critical workflows with defined states | Medium | Low |

### Decision Flow

```
Is the task single-step?
  Yes → Single-turn tool use
  No →
    Is the task structure known in advance?
      Yes → Plan-and-execute
      No →
        Does it need multiple specialist capabilities?
          Yes →
            Must sub-agents coordinate?
              Yes → Supervisor
              No → Swarm (parallel) or Router (serial)
          No → ReAct loop
    Does the output need verification?
      Yes → Add debate/critique layer
```

> For detailed pattern specifications and TypeScript implementations, see [references/architecture-patterns.md](references/architecture-patterns.md).

## Implementation Layers

Every agentic harness has five layers. The skill generates code for each:

| Layer | Responsibility | Key Components |
|-------|---------------|----------------|
| **Transport** | LLM communication | API client, retry logic, streaming, model routing |
| **Orchestration** | Agent loop control | State machine, turn management, tool dispatch, routing |
| **Tool** | External capability | Tool registry, schema validation, sandboxing, result parsing |
| **Guard** | Safety enforcement | Input filters, output validators, cost limits, rate limits |
| **Memory** | State persistence | Conversation history, vector store, episodic memory, compaction |

### Scaffold Output

When generating a harness, the skill produces:

```
agent-harness/
├── src/
│   ├── agent.ts                 # Main agent loop (orchestration layer)
│   ├── transport/
│   │   ├── llm-client.ts        # LLM API client with retry/streaming
│   │   ├── model-router.ts      # Multi-model routing (cost/capability)
│   │   └── types.ts             # Message types, tool call types
│   ├── tools/
│   │   ├── registry.ts          # Tool registration and dispatch
│   │   ├── sandbox.ts           # Tool execution sandboxing
│   │   ├── schemas.ts           # Tool input/output validation (Zod)
│   │   └── builtin/             # Built-in tools (file, web, code-exec)
│   ├── guards/
│   │   ├── input-filter.ts      # Prompt injection detection
│   │   ├── output-validator.ts  # Output safety + format validation
│   │   ├── cost-limiter.ts      # Per-request and per-session cost caps
│   │   └── rate-limiter.ts      # Request rate limiting
│   ├── memory/
│   │   ├── conversation.ts      # Short-term conversation state
│   │   ├── vector-store.ts      # Long-term semantic memory
│   │   ├── compaction.ts        # Context window management
│   │   └── episodic.ts          # Experience replay / learning
│   ├── observability/
│   │   ├── logger.ts            # Structured logging
│   │   ├── tracer.ts            # Distributed tracing (OpenTelemetry)
│   │   ├── metrics.ts           # Cost, latency, token usage
│   │   └── anomaly.ts           # Behavioral anomaly detection
│   └── config.ts                # Harness configuration
├── eval/
│   ├── runner.ts                # Eval pipeline runner
│   ├── datasets/                # Eval datasets (JSONL)
│   ├── scorers/                 # Custom scoring functions
│   ├── reporters/               # Results formatting (JSON, HTML)
│   └── suites/
│       ├── accuracy.eval.ts     # Task completion accuracy
│       ├── safety.eval.ts       # Safety boundary testing
│       ├── injection.eval.ts    # Prompt injection resistance
│       ├── latency.eval.ts      # Performance benchmarks
│       └── regression.eval.ts   # Behavioral regression tests
├── tests/
│   ├── unit/                    # Unit tests for each layer
│   ├── integration/             # Integration tests with mock LLM
│   └── e2e/                     # End-to-end with real LLM calls
├── package.json
├── tsconfig.json
└── README.md
```

> For the full scaffold specification, see [references/harness-scaffold-guide.md](references/harness-scaffold-guide.md).

## Evaluation Framework

### Eval Types

| Type | What It Measures | When to Run | Cost |
|------|-----------------|-------------|------|
| **Accuracy** | Task completion rate against ground truth | Pre-deploy, on model change | Medium |
| **Safety** | Boundary adherence (refusal, guardrails) | Pre-deploy, weekly | Medium |
| **Injection resistance** | Defense against adversarial inputs | Pre-deploy, on guard changes | Low |
| **Latency** | Time-to-first-token, total response time | Pre-deploy, continuous | Low |
| **Cost** | Token usage, API cost per task | Continuous | Negligible |
| **Regression** | Behavioral stability across versions | Pre-deploy, on any change | High |
| **Red team** | Adversarial capability probing | Quarterly, on major changes | High |

### Eval-Driven Development Workflow

```
1. Define agent capability as eval cases
2. Write scoring functions
3. Run evals → establish baseline (expect failure)
4. Implement agent logic
5. Run evals → measure improvement
6. Iterate until passing threshold
7. Add eval cases to regression suite
8. Deploy with continuous eval monitoring
```

> For eval implementation details, see [references/eval-framework.md](references/eval-framework.md).
> For eval pipeline code generation, see [references/eval-implementation.md](references/eval-implementation.md).

## Security Model

### OWASP LLM Top 10 Coverage

| # | Threat | Defense Layer | Implementation |
|---|--------|--------------|----------------|
| LLM01 | Prompt Injection | Guard (input) | Multi-layer detection: heuristic + classifier + canary tokens |
| LLM02 | Insecure Output Handling | Guard (output) | Output sanitization, format validation, content policy |
| LLM03 | Training Data Poisoning | N/A (out of scope) | — |
| LLM04 | Model Denial of Service | Guard (rate/cost) | Token budgets, request rate limits, timeout enforcement |
| LLM05 | Supply Chain Vulnerabilities | Tool layer | Tool allowlisting, dependency auditing, version pinning |
| LLM06 | Sensitive Information Disclosure | Guard (output) + Memory | PII detection, output scrubbing, memory access control |
| LLM07 | Insecure Plugin Design | Tool layer | Schema validation, least-privilege sandbox, result size limits |
| LLM08 | Excessive Agency | Orchestration | Human-in-the-loop gates, action confirmation, scope limits |
| LLM09 | Overreliance | Eval + UI | Confidence scoring, uncertainty surfacing, source attribution |
| LLM10 | Model Theft | Transport | API key rotation, request signing, audit logging |

### Defense-in-Depth Stack

```
┌─────────────────────────────────────┐
│         Input Guards                │  ← Injection detection, PII scrub
├─────────────────────────────────────┤
│         Rate / Cost Limits          │  ← Token budgets, request caps
├─────────────────────────────────────┤
│         Tool Sandbox                │  ← Allowlist, schema validation
├─────────────────────────────────────┤
│         Output Validators           │  ← Format check, content policy
├─────────────────────────────────────┤
│         Audit Log                   │  ← Every decision recorded
├─────────────────────────────────────┤
│         Human-in-the-Loop           │  ← High-risk action approval
└─────────────────────────────────────┘
```

> For the complete threat model, see [references/security-threat-model.md](references/security-threat-model.md).
> For security implementation code, see [references/security-implementation.md](references/security-implementation.md).
> For prompt injection defense deep dive, see [references/prompt-injection-defense.md](references/prompt-injection-defense.md).

## Observability

### Telemetry Schema

Every LLM call emits a structured event:

```typescript
interface AgentTelemetry {
  trace_id: string;
  span_id: string;
  timestamp: number;
  event_type: 'llm_call' | 'tool_call' | 'guard_trigger' | 'state_transition';
  model: string;
  tokens: { input: number; output: number; cached: number };
  latency_ms: number;
  cost_usd: number;
  tool_name?: string;
  guard_name?: string;
  guard_action?: 'pass' | 'warn' | 'block';
  error?: string;
}
```

### Dashboards

The skill generates OpenTelemetry-compatible instrumentation that feeds into any OTLP backend (Grafana, Datadog, etc.):

- **Agent health** — Success rate, error rate, avg latency, P99 latency
- **Cost tracking** — Per-model, per-agent, per-user cost breakdown
- **Guard activity** — Trigger frequency, false positive rate, blocked requests
- **Tool usage** — Call frequency, success rate, latency per tool
- **Behavioral drift** — Embedding-based output similarity over time

> For observability implementation, see [references/observability-guide.md](references/observability-guide.md).

## Quick Start Guides

### Build an Agent from Scratch
1. Fill out [harness-brief-worksheet.md](assets/harness-brief-worksheet.md)
2. Select architecture pattern from the Pattern Selection Matrix
3. Generate harness scaffold
4. Write eval cases first (eval-driven development)
5. Implement agent logic layer by layer (transport → tools → orchestration → guards → memory)
6. Run security checklist [security-checklist.md](assets/security-checklist.md)
7. Add observability instrumentation
8. Deploy with continuous eval monitoring

### Add Security to an Existing Agent
1. Run threat model against [security-threat-model.md](references/security-threat-model.md)
2. Identify undefended attack surfaces
3. Generate guard layer code for each gap
4. Run injection eval suite to validate
5. Complete [security-checklist.md](assets/security-checklist.md)

### Build an Eval Suite
1. Define capabilities as eval dimensions
2. Curate or generate eval datasets
3. Implement scoring functions
4. Run baseline, establish thresholds
5. Add to CI/CD pipeline
6. Monitor regression over time

### Red-Team an Agent
1. Review [red-teaming-guide.md](references/red-teaming-guide.md) for methodology
2. Select attack categories relevant to the agent's capabilities
3. Generate adversarial test cases
4. Run attacks, document findings
5. Implement defenses for each finding
6. Re-run attacks to validate fixes

## Reference Guide

| Task | Read These |
|------|-----------|
| **Starting any agent project** | `architecture-patterns.md`, `harness-scaffold-guide.md` |
| **Choosing an architecture** | `architecture-patterns.md` (pattern selection matrix) |
| **Implementing tools** | `tool-integration-guide.md` |
| **Adding memory** | `memory-and-state.md` |
| **Multi-agent design** | `multi-agent-coordination.md` |
| **Building evals** | `eval-framework.md`, `eval-implementation.md` |
| **Security hardening** | `security-threat-model.md`, `security-implementation.md` |
| **Prompt injection defense** | `prompt-injection-defense.md` |
| **Red-teaming** | `red-teaming-guide.md` |
| **Observability** | `observability-guide.md` |
| **Deployment** | `deployment-patterns.md` |
| **Agent UIs** | `ui-patterns.md` |
| **Full walkthrough** | `worked-example-claude-harness.md` |
| **Eval walkthrough** | `worked-example-eval-pipeline.md` |

All paths relative to `references/`.

## Related Skills

- **trl-mcp-builder** / **trl-mcp-architect** / **trl-mcp-forge** — For building MCP tool servers that agents consume
- **claude-api** — For Claude-specific API features (caching, thinking, batch, tool use)
- **trl-threat-modeler** — For formal threat modeling methodology (STRIDE, PASTA, attack trees)
- **trl-dba-db-designer-and-tuning** — For designing databases backing agent memory and state
- **trl-user-experience-engineer** — For agent chat UIs, admin dashboards, approval workflows
- **trl-skill-engineer** — For packaging agent capabilities as reusable skills
- **trl-seo-guru** — For optimizing agent-generated content for search engines

## Bundled Resources

### References

**Architecture** (read first):
- [architecture-patterns.md](references/architecture-patterns.md) — Agentic patterns: ReAct, plan-and-execute, router, supervisor, swarm, debate, state machine
- [harness-scaffold-guide.md](references/harness-scaffold-guide.md) — Complete scaffold specification with TypeScript implementations
- [tool-integration-guide.md](references/tool-integration-guide.md) — Tool registration, schema validation, sandboxing, error handling
- [memory-and-state.md](references/memory-and-state.md) — Conversation, vector store, episodic memory, compaction strategies
- [multi-agent-coordination.md](references/multi-agent-coordination.md) — Multi-agent patterns, message passing, shared state, deadlock prevention

**Evaluation** (read before deploying):
- [eval-framework.md](references/eval-framework.md) — Eval methodology: types, scoring, datasets, thresholds, CI integration
- [eval-implementation.md](references/eval-implementation.md) — TypeScript eval pipeline code generation
- [red-teaming-guide.md](references/red-teaming-guide.md) — Adversarial testing methodology and attack taxonomy

**Security** (read before shipping):
- [security-threat-model.md](references/security-threat-model.md) — OWASP LLM Top 10 mapping, attack trees, defense strategies
- [security-implementation.md](references/security-implementation.md) — Guard layer code: input filters, output validators, sandboxing
- [prompt-injection-defense.md](references/prompt-injection-defense.md) — Deep dive: injection taxonomy, detection methods, canary tokens

**Operations**:
- [observability-guide.md](references/observability-guide.md) — OpenTelemetry instrumentation, dashboards, alerting
- [deployment-patterns.md](references/deployment-patterns.md) — Production deployment: scaling, failover, rate limiting, cost control
- [ui-patterns.md](references/ui-patterns.md) — Chat interfaces, admin dashboards, tool approval workflows

**Execution**:
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role definition and execution workflows

**Worked Examples**:
- [worked-example-claude-harness.md](references/worked-example-claude-harness.md) — End-to-end: building a Claude-based agentic system
- [worked-example-eval-pipeline.md](references/worked-example-eval-pipeline.md) — End-to-end: building an eval suite for an existing agent

### Assets

- [harness-brief-worksheet.md](assets/harness-brief-worksheet.md) — Intake form for agent requirements, capabilities, constraints
- [security-checklist.md](assets/security-checklist.md) — Pre-deployment security gate checklist
- [eval-scorecard.md](assets/eval-scorecard.md) — Eval results template with scoring dimensions
- [architecture-decision-record.md](assets/architecture-decision-record.md) — ADR template for agent design decisions
