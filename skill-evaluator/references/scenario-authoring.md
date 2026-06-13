# Scenario Authoring Guide

## What Makes a Good Scenario

A scenario is a contract: "given this input, the skill should produce this flow." Good scenarios test specific capabilities, have clear pass/fail criteria, and include recovery paths for realistic failures.

### Anatomy

Every scenario has five parts:
1. **Metadata** — name, difficulty, tags
2. **Task** — the instruction sent to the skill
3. **Flow graph** — directed graph of expected execution steps
4. **Recovery paths** — what to do when execution deviates
5. **Success criteria** — boolean conditions for pass/fail

### Flow Graph Design

The flow graph is the core of a scenario. Think of it as a test oracle: you define what *should* happen, and the evaluator compares actual execution against it.

#### Node Types

| Type | Purpose | Required Fields |
|------|---------|-----------------|
| `trigger` | Entry point, skill receives instruction | `action` |
| `action` | Skill performs an expected action | `expected_action`, `expected_tools`, `on_success`, `on_failure` |
| `decision` | Skill makes a choice (branching) | `expected_action`, `branches` (list of condition→node) |
| `observe` | Skill reads/perceives state | `expected_action`, `expected_content` |
| `terminal` | End of flow | `expected_action`, `success_criteria` |

#### Edge Design

Edges define transitions between nodes. Every `action` node must have:
- `on_success` — node to advance to on success
- `on_failure` — node to advance to on failure (or recovery path ID)

For decision nodes, use `branches` instead:
```yaml
branches:
  - condition: "File exists"
    target: step-2a
  - condition: "File does not exist"
    target: step-2b
```

#### Well-Formed Flow Rules

1. **Reachability**: Every non-terminal node must have a path to a terminal
2. **Termination**: No cycles without exit conditions
3. **Failure coverage**: Every action node has a failure path
4. **Determinism**: Given the same state, the flow is unambiguous

#### Flow Patterns

**Linear Flow** (easy scenarios):
```yaml
nodes:
  - id: start
    type: trigger
    action: "Skill receives instruction"
  - id: step-1
    type: action
    expected_action: "Read config"
    expected_tools: [Read]
    on_success: step-2
    on_failure: fail
  - id: step-2
    type: terminal
    action: "Report results"
```

**Branching Flow** (medium scenarios):
```yaml
nodes:
  - id: start
    type: trigger
  - id: check
    type: decision
    expected_action: "Check if file exists"
    branches:
      - condition: "exists"
        target: process
      - condition: "missing"
        target: create
  - id: process
    type: action
    on_success: done
    on_failure: recover
  - id: create
    type: action
    on_success: done
    on_failure: fail
  - id: done
    type: terminal
```

**Recovery Flow** (hard scenarios):
```yaml
nodes:
  - id: start
    type: trigger
  - id: attempt
    type: action
    on_success: done
    on_failure: recover-1
  - id: done
    type: terminal

recovery_paths:
  - id: recover-1
    trigger: "File not found"
    evaluator_action: "Provide correct path"
    expected_skill_response: "Retry with correct path"
    max_retries: 2
```

### Difficulty Guidelines

| Level | Characteristics | Example |
|-------|----------------|---------|
| **Easy** | Linear flow, 2-4 nodes, no branching, no recovery | Basic invocation that reads a file and returns output |
| **Medium** | Branching flow, 4-8 nodes, one recovery path | Multi-step workflow with a decision point |
| **Hard** | Complex flow, 8+ nodes, multiple recoveries, edge cases | Multi-phase evaluation with interactive recovery |
| **Adversarial** | Intentionally misleading input, contradictory constraints | Instruction that conflicts with skill's stated scope |

### Anti-Patterns

| Anti-Pattern | Why It's Bad | Fix |
|-------------|--------------|-----|
| Happy-path only | Doesn't test failure handling | Add failure nodes and recovery paths |
| Vague expected_action | Can't determine if skill matched | Be specific: "Read file X using Read tool" |
| Missing failure edges | Evaluator doesn't know what to do on failure | Every action needs on_failure |
| Too many nodes | Unmaintainable, noisy | Split into multiple scenarios |
| No validation | Can't determine if output is correct | Add `validation` with concrete checks |
| Phantom recovery | Recovery path that can't actually trigger | Ensure trigger conditions are realistic |
