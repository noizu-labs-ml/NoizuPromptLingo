# Agent Prompt Patterns

> Prompt patterns specific to agentic AI systems — orchestration, multi-agent coordination, memory, and flow engineering. Use when designing skills that spawn sub-agents or operate as autonomous pipelines.

---

## Orchestration Patterns

### Meta-Prompting (Orchestrator Mode)
**Source:** Suzgun & Kalai, arxiv:2401.12954  
**Mechanism:** Single LLM acts as orchestrator, dynamically spawning expert sub-agents per subtask.  
**Results:** +17.1% over standard prompting on GPT-4 benchmarks  
**When:** Complex multi-domain tasks that need different expertise per sub-problem.

```
SYSTEM: You are a meta-orchestrator. When given a task:
1. Identify what expert sub-role is needed
2. Spawn: "You are an expert [X]. Solve: [subtask]"
3. Collect results and synthesize
4. If results conflict, resolve contradictions explicitly
```

**Skill integration:** Wire into agent playbook as the top-level dispatch pattern. Map to Claude Code's `Agent()` tool with `subagent_type` selection.

### Prompt Chaining (DAG)
**Source:** arxiv:2512.23049 (Prompt Choreography)  
**Results:** Up to 15.6% accuracy over monolithic prompts  

| Pattern | Structure | Prompt Contract |
|:---|:---|:---|
| **Linear** | A → B → C | Each step: input format + output format |
| **Branching/DAG** | A → [B, C parallel] → D | Merge step must handle conflicting outputs |
| **Conditional routing** | A → router → B or C | Router is pure classifier; specialists are deep |
| **Iterative refinement** | A → critic → revise → exit when pass | Define explicit exit criteria |

**Skill integration:** Structure agent playbook workflows as explicit chains with typed handoffs.

---

## Multi-Agent Patterns

### Reflexion
**Source:** Shinn et al. OpenReview; ReflectEvo ACL 2025  
**Mechanism:** After attempt, generate verbal feedback → store in episodic memory → condition next attempt.  
**Key difference from self-critique:** Maintains memory across trials.

```
ATTEMPT 1: "Solve [problem]."
CRITIC: "What step failed? What should change?"
ATTEMPT 2: "Solve again. Reflection: [feedback]. Incorporate this."
```

### Multi-Agent Reflexion (MAR)
**Source:** arxiv:2512.20845  
**Mechanism:** Multiple critic agents with diverse personas. Each generates different critique; reasoner synthesizes. Reduces confirmation bias.  
**Skill integration:** When single-model self-critique keeps missing the same failure mode, spawn a DIFFERENT persona/tasker tier for the retry.

### Evaluator-Optimizer Loop
**Mechanism:** Generator produces → Evaluator scores against rubric → loop until threshold.

```
GENERATOR: Produce [output] for [task].
EVALUATOR: Score [1-5] on: accuracy, completeness, clarity.
  If all ≥ 4: accept.
  Else: send critique back. Max 3 iterations.
  If stuck: escalate to user with best attempt + feedback.
```

**Skill integration:** Natural pattern for skills that iterate on quality (content generation, code review, design).

### Boosting of Thoughts
**Source:** arxiv:2402.11140  
**Mechanism:** AdaBoost for reasoning — weight subsequent trials toward cases where prior trials failed.  
**Skill integration:** Hard evaluation suites where some sub-problems consistently fail.

---

## Topology Selection

When designing a multi-agent skill, choose the right coordination pattern:

| Topology | When | Prompt Requirements |
|:---|:---|:---|
| **Pipeline** | Steps are sequential and independent | Each agent: input format + output format contract |
| **Supervisor** | Tasks need routing to specialists | Supervisor: delegation schema + worker capability inventory |
| **Router** | Input type determines specialist | Router: pure classifier. Specialists: deep, narrow |
| **Swarm** | Emergent exploration needed | Each agent: own goal, peer protocol, termination condition |

### Pipeline Example
```
Agent_1 (Extract) → Agent_2 (Analyze) → Agent_3 (Format)
Each agent's prompt defines:
  - Expected input schema
  - Transformation responsibility
  - Output schema
  - Error handling: what to pass through vs. flag
```

### Supervisor Example
```
Supervisor Agent
├── Worker A (code analysis)
├── Worker B (security review)
└── Worker C (performance audit)

Supervisor prompt includes:
  - Delegation criteria (which worker for which task type)
  - Worker capability descriptions
  - Synthesis rules (how to merge conflicting worker outputs)
  - Escalation rules (when to ask user)
```

---

## Memory Patterns for Agents

**Source:** arxiv:2603.07670 (Memory for Autonomous LLM Agents)

| Memory Type | Storage | Prompt Pattern | Challenge |
|:---|:---|:---|:---|
| **Sensory/In-context** | Context window | Direct inclusion | Token budget |
| **Episodic** | External store (vector DB) | RAG retrieval | Precision, recency bias |
| **Semantic** | Structured KB / graph | Lookup + inject | Schema alignment |
| **Procedural** | Fine-tuned weights or tool defs | Implicit | Slow to update |

### Hierarchical Memory Architecture
```
Tier 1: Current turn (raw, full fidelity)
Tier 2: Session summary (compressed, regenerated every N turns)
Tier 3: User profile (persistent, structured, manually curated)
Tier 4: Knowledge base (retrieved on demand, not injected wholesale)
```

**Skill integration:** Map to Claude Code's memory system — Tier 1 is context, Tier 2 is conversation compression, Tier 3 is `.claude/memory/`, Tier 4 is `docs/` or external retrieval.

---

## Flow Engineering

**Source:** Anthropic Engineering Blog 2025; SitePoint 2026  

The paradigm shift: prompt tricks are second-order. Highest leverage is **flow design** — control flow and decision boundaries *around* LLM calls.

### Six Canonical Agentic Flows

| Flow | Structure | Skill Pattern |
|:---|:---|:---|
| **Prompt chaining** | Linear pipeline | Sequential agent playbook steps |
| **Routing** | Classify → dispatch | Trigger language + conditional workflows |
| **Parallelization** | Independent calls, merge | `Agent()` with `run_in_background` |
| **Orchestrator-subagent** | Planner → executors | Meta-prompting + persona spawning |
| **Evaluator-optimizer** | Generate + score loop | Quality iteration in content/code skills |
| **Human-in-the-loop** | Pause at high-stakes | `AskUserQuestion` at decision points |

### Flow Selection Guide

```
Is the task decomposable into independent parts?
  YES → Parallelization
  NO → Is it decomposable into sequential parts?
    YES → Pipeline
    NO → Is input type the primary decision factor?
      YES → Router
      NO → Does it need iterative quality improvement?
        YES → Evaluator-Optimizer
        NO → Does it need multiple expert perspectives?
          YES → Orchestrator-Subagent
          NO → Simple single-agent with appropriate reasoning pattern
```

---

## Security Patterns for Agents

### Plan-Execute Security Gate
**Source:** arxiv:2506.08837  
Commit to tool plan BEFORE ingesting untrusted data. Content cannot modify plan.

### Instruction Hierarchy in Multi-Agent Systems
Each agent in a multi-agent system needs its own instruction hierarchy:
- Agent's system prompt (P0 for that agent)
- Supervisor's instructions (P1)
- Other agents' messages (P2)
- Tool results (P3)
- External content (P4 — untrusted)

### Tool Use Hardening
**Source:** Composio 2026; arxiv:2605.09252  
- Keep tool descriptions concise and precise — over-explaining hurts performance
- Include "when NOT to use" in tool descriptions
- Limit tool count to ~10 per agent (beyond that, use a router)
- Parallel tool calling requires explicit permission in the prompt
