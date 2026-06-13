# Architecture Decision Record Template

Standard ADR format adapted for agentic systems. Copy this template for each significant architectural decision. Store ADRs in `docs/decisions/` within the agent project. Name files `ADR-NNNN-short-title.md`.

---

## ADR-NNNN: [Short Title]

**Status:** [ ] Proposed  [ ] Accepted  [ ] Deprecated  [ ] Superseded by ADR-____  
**Date:** YYYY-MM-DD  
**Authors:** _______________  
**Reviewers:** _______________  

---

## Context

> Describe the situation that necessitates this decision. What problem are we solving? What forces are in tension? What constraints apply?

```
[Fill in — be specific about what drove this decision. Include:
- Business or user requirements that created the need
- Technical constraints (existing systems, dependencies, compliance)
- Performance, cost, or operational pressures
- Timeline pressures, if relevant
Do not describe the decision here — only the context that makes it necessary.]
```

**Key constraints:**
- 
- 
- 

**Stakeholders affected:**
- 
- 

---

## Decision

> State the decision clearly and unambiguously. One decision per ADR.

```
We will [decision statement].
```

**Decision summary:**
```
[1-3 sentences: what we decided and the core rationale in brief]
```

---

## Consequences

### Positive Consequences

> What becomes easier, better, or possible because of this decision?

- 
- 
- 

### Negative Consequences

> What becomes harder, worse, or more constrained because of this decision?

- 
- 
- 

### Risks

> What could go wrong? What assumptions does this decision depend on?

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| | [ ] Low [ ] Med [ ] High | [ ] Low [ ] Med [ ] High | |
| | [ ] Low [ ] Med [ ] High | [ ] Low [ ] Med [ ] High | |
| | [ ] Low [ ] Med [ ] High | [ ] Low [ ] Med [ ] High | |

---

## Alternatives Considered

> List the options that were evaluated and explain why they were rejected.

### Option A: [Name]

**Description:**
```
[What this option involves]
```

**Pros:**
- 
- 

**Cons:**
- 
- 

**Why rejected:**
```
[Specific reason this option was not chosen]
```

---

### Option B: [Name]

**Description:**
```
[What this option involves]
```

**Pros:**
- 
- 

**Cons:**
- 
- 

**Why rejected:**
```
[Specific reason this option was not chosen]
```

---

### Option C: Do Nothing / Status Quo

**Description:** Keep the current approach unchanged.

**Why rejected:**
```
[Why this is not an acceptable option]
```

---

## Agent-Specific Sections

### Pattern Selection Rationale

> Which agentic design pattern was chosen, and why?

**Pattern selected:**
```
[ ] ReAct (Reasoning + Acting loop)
[ ] Plan-then-execute (upfront planning, then sequential execution)
[ ] Supervisor + worker (orchestrator delegates to sub-agents)
[ ] Pipeline (fixed stage sequence)
[ ] Mixture of experts / routing (classifier routes to specialized agents)
[ ] Custom: _______________
```

**Why this pattern fits the use case:**
```
[Explain how the pattern maps to the requirements. What properties of this pattern
make it the right choice — e.g., ReAct handles open-ended tasks well because it
can adapt its plan based on intermediate results; plan-then-execute is better when
the task is well-defined and reversibility matters.]
```

**Pattern trade-offs accepted:**
```
[Every pattern has weaknesses. Name the weaknesses of the chosen pattern and how
they are mitigated. E.g., "ReAct loops can spiral — we cap max iterations at 10
and add a budget guard."]
```

---

### Tool Selection Rationale

> Which tools were included and excluded, and why?

**Tools included:**

| Tool | Purpose | Why included | Alternatives considered |
|------|---------|-------------|------------------------|
| | | | |
| | | | |
| | | | |

**Tools explicitly excluded:**

| Tool considered | Why excluded |
|----------------|-------------|
| | |
| | |

**Tool scope decision:**
```
[Was there a deliberate choice about how broad or narrow the tool set should be?
Narrow tool sets are easier to secure and reason about; broad tool sets increase
capability but also attack surface. Record the trade-off decision here.]
```

---

### Security Trade-offs

> What security properties does this decision affect, and what trade-offs were accepted?

**Security properties affected:**

| Property | Effect | Trade-off accepted |
|----------|--------|-------------------|
| Prompt injection attack surface | [ ] Reduced [ ] Increased [ ] Unchanged | |
| Blast radius of misuse | [ ] Reduced [ ] Increased [ ] Unchanged | |
| Credential exposure risk | [ ] Reduced [ ] Increased [ ] Unchanged | |
| Auditability | [ ] Improved [ ] Degraded [ ] Unchanged | |
| Data privacy | [ ] Improved [ ] Degraded [ ] Unchanged | |

**Security assumptions this decision depends on:**
```
[List any security assumptions that must hold for this decision to be safe.
E.g., "This assumes all tool outputs are from trusted sources. If external content
is added later, injection mitigations must be revisited."]
```

**Residual risks accepted:**
```
[Any known security weaknesses that are accepted as out-of-scope for this decision,
with rationale. Accepted risks should have a corresponding item in the security
checklist or a follow-up ADR.]
```

---

## Implementation Notes

> Guidance for implementers that flows from this decision.

```
[Optional — any specific implementation constraints, patterns, or pitfalls that
engineers should know when implementing this decision]
```

**Definition of done for this ADR:**
- [ ] Decision implemented
- [ ] Tests cover the new approach
- [ ] Security checklist updated if applicable
- [ ] Downstream ADRs created if this decision has dependencies

---

## Related ADRs

| ADR | Relationship |
|-----|-------------|
| ADR-____ | Supersedes |
| ADR-____ | Depends on |
| ADR-____ | Related to |

---

## References

- 
- 
