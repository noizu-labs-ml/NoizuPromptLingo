# Agent Brief Worksheet

Fill this out before building an agent. Complete sections become the design spec.

---

## 1. Core Purpose

**What does this agent do?** (1-2 sentences)

> _[Fill in]_

**What triggers it?** (User says "...", event occurs, scheduled, etc.)

> _[Fill in]_

**What does "done" look like?** (Specific success criteria)

> _[Fill in]_

---

## 2. Complexity Assessment

**Can this be done in a single LLM call?** Yes / No

**Does it need external tools?** Yes / No → If yes, list them:

| Tool | What It Does | Exists or Build? |
|------|-------------|-----------------|
| | | |

**Are there sequential steps?** Yes / No → If yes, list them:

1. _[Step]_
2. _[Step]_
3. _[Step]_

**Are steps independent (parallelizable)?** Yes / No

**Is task decomposition dynamic?** Yes / No

**Recommended Complexity Level:** _[0-7, see Complexity Ladder]_

---

## 3. Lifecycle

**Ephemeral or long-lived?**

- [ ] Ephemeral — one task per invocation, no state
- [ ] Long-lived — persists across turns/sessions, maintains state

**Who does it report to?**

- [ ] User directly
- [ ] Another agent (orchestrator/controller)
- [ ] Both

**Autonomy level:**

- [ ] Low — asks for confirmation at each step
- [ ] Medium — acts independently but reports results
- [ ] High — works autonomously until complete or blocked

---

## 4. Context Requirements

| Layer | Needed? | Content | Notes |
|-------|---------|---------|-------|
| System instructions | Yes (always) | | |
| Conversation history | | | |
| Retrieved knowledge | | | |
| Persistent memory | | | |
| Tool definitions | | | |
| Task state (scratchpad) | | | |
| Guardrail context | Yes (always) | | |

---

## 5. Failure Modes

**What can go wrong?** List the top 5 failure scenarios:

| Failure | Likelihood | Impact | Mitigation |
|---------|-----------|--------|------------|
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |

---

## 6. Guardrails

**What must this agent NEVER do?**

1. _[Constraint]_
2. _[Constraint]_
3. _[Constraint]_

**What must it ALWAYS do?**

1. _[Requirement]_
2. _[Requirement]_
3. _[Requirement]_

---

## 7. NPL Integration (Optional)

**Would NPL add value?** Yes / No / Maybe

If yes, which patterns?

- [ ] `<npl-intent>` — Agent makes assumptions that should be surfaced
- [ ] `<npl-ref>` — Agent should self-assess its output
- [ ] `<npl-poa>` — Agent makes decisions with multiple viable paths
- [ ] `<npl-cot>` — Complex reasoning that should be transparent
- [ ] `<npl-vos>` + hormones — Persona-driven with behavioral state
- [ ] `<npl-mindread>` — Needs to model user intent
- [ ] `<npl-critique>` — Evaluates quality of its own or others' work

---

## 8. Output Specification

**What format should the agent's output take?**

```yaml
# Define the response structure
status: [enum values]
# ... additional fields
```

**Who consumes the output?** (User, another agent, a system)

> _[Fill in]_

---

## 9. Test Scenarios

List 5+ scenarios to validate against:

| Scenario | Input | Expected Behavior |
|----------|-------|-------------------|
| Happy path | | |
| Edge case 1 | | |
| Error case | | |
| Guardrail test | | |
| Adversarial | | |
