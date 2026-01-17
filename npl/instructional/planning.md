# Planning & Reasoning Patterns
<!-- labels: [planning, reasoning, cognitive] -->

Advanced thinking techniques and structured reasoning approaches for complex problem-solving and agent behavior orchestration.

<!-- instructional: conceptual-explanation | level: 0 | labels: [planning, overview] -->
## Overview

Planning in NPL encompasses structured reasoning techniques, thinking patterns, and cognitive frameworks that guide agents through complex problem-solving processes. These patterns provide systematic approaches to breaking down problems, analyzing solutions, and constructing well-reasoned responses.

<!-- instructional: quick-reference | level: 0 | labels: [planning, components] -->
## Core Planning Components

| Component | Tag | Purpose |
|-----------|-----|---------|
| Intent Blocks | `<npl-intent>` | Document decision-making process |
| Chain of Thought | `<npl-cot>` | Systematic problem decomposition |
| Reflection Blocks | `<npl-reflection>` | Self-assessment and learning |

### Intent Blocks
<!-- level: 0 | labels: [intent, transparency] -->
`npl-intent` - Structured transparency into agent decision-making processes.

```syntax
<npl-intent>
intent:
  overview: <brief description of intent>
  steps:
    - <step 1>
    - <step 2>
    - <step 3>
</npl-intent>
```

**Usage**: Include at the beginning of complex responses or when debugging mode is active.

### Chain of Thought
<!-- level: 1 | labels: [cot, decomposition, reasoning] -->
`npl-cot` - Structured problem decomposition and systematic reasoning with explicit reflection and correction mechanisms.

```syntax
<npl-cot>
thought_process:
  - thought: "Initial assessment of the problem"
    understanding: "What the problem involves"
    theory_of_mind: "Intent behind the question"
    plan: "Approach to solving it"
    rationale: "Why this approach"
    execution:
      - process: "Implementation steps"
        reflection: "Assessment of progress"
        correction: "Adjustments made"
  outcome: "Final conclusion"
</npl-cot>
<npl-conclusion>
Final solution or answer to the problem.
</npl-conclusion>
```

**Usage**: Apply to multi-step problems requiring structured analysis and verification.

### Reflection Blocks
<!-- level: 0 | labels: [reflection, evaluation, learning] -->
`npl-reflection` - Self-assessment and continuous improvement mechanisms.

```syntax
<npl-reflection>
reflection:
  overview: |
    <assessment of response quality and effectiveness>
  observations:
    - <emoji> <specific observation 1>
    - <emoji> <specific observation 2>
    - <emoji> <specific observation 3>
</npl-reflection>
```

<!-- instructional: quick-reference | level: 0 | labels: [emojis, indicators] -->
**Reflection Type Indicators**:

| Emoji | Meaning | Emoji | Meaning |
|-------|---------|-------|---------|
| ✅ | Success | ❌ | Error identified |
| 🔧 | Improvement needed | 💡 | Insight/learning |
| 🔄 | Review needed | 🆗 | Acceptable |
| ⚠️ | Warning | ➕ | Positive aspect |
| ➖ | Negative aspect | ✏️ | Clarification needed |

**Usage**: Include at the end of responses for self-evaluation and learning documentation.

---

<!-- instructional: quick-reference | level: 1 | labels: [advanced, patterns] -->
## Advanced Planning Patterns

| Pattern | Tag | Purpose |
|---------|-----|---------|
| Critique Systems | `<npl-critique>` | Systematic quality assessment |
| Rubric Assessment | `<npl-rubric>` | Standardized evaluation criteria |
| Panel Discussions | `<npl-panel>` | Multi-perspective analysis |
| Tangential Exploration | `<npl-tangent>` | Controlled related concept exploration |


---

<!-- instructional: integration-pattern | level: 1 | labels: [integration, agents] -->
## Integration Patterns

### Planning with Agent Behaviors
<!-- level: 1 -->
```example
⌜analyst-agent|service|NPL@1.0⌝
# Data Analyst Agent
Provides structured analysis with built-in reasoning transparency.

## Default Response Pattern
All responses should include:
1. <npl-intent> block outlining analysis approach
2. <npl-cot> for complex data interpretation
3. <npl-reflection> for quality assessment

⌞analyst-agent⌟
```

<!-- instructional: decision-guide | level: 1 | labels: [conditional, selection] -->
### Conditional Planning Application

Apply planning patterns based on:
- Query complexity level
- User request for transparency
- Debugging or development mode
- Agent learning phases

<!-- instructional: usage-guideline | level: 1 | labels: [layered, workflow] -->
### Layered Reasoning Approaches

| Stage | Pattern | Purpose |
|-------|---------|---------|
| 1 | Intent | Document planned approach |
| 2 | Chain of Thought | Execute structured reasoning |
| 3 | Critique | Evaluate solution quality |
| 4 | Reflection | Learn for future improvements |

---

<!-- instructional: usage-guideline | level: 1 | labels: [configuration, runtime] -->
## Planning Pattern Configuration

### Runtime Flags for Planning
```syntax
⌜🏳️
🏳️planning.intent_blocks = conditional
🏳️planning.reflection_mode = learning
🏳️planning.cot_verbosity = detailed
⌟
```

### Agent-Specific Planning Settings
```syntax
🏳️@research_agent.planning.reflection_required = true
🏳️@simple_agent.planning.intent_minimal = true
```

---

<!-- instructional: lifecycle | level: 2 | labels: [complex, multi-stage] -->
## Complex Reasoning Structures

### Multi-Stage Problem Solving

| Stage | Action |
|-------|--------|
| 1. Problem Decomposition | Break into manageable components |
| 2. Solution Exploration | Identify possible approaches |
| 3. Option Evaluation | Assess trade-offs and constraints |
| 4. Implementation Planning | Structure execution steps |
| 5. Outcome Validation | Verify solution effectiveness |

### Collaborative Reasoning
<!-- level: 2 -->
```example
<npl-panel>
perspectives:
  - role: "Technical Expert"
    viewpoint: "Implementation feasibility and constraints"
  - role: "User Experience Designer"
    viewpoint: "Usability and user impact"
  - role: "Business Analyst"
    viewpoint: "Cost-benefit and strategic alignment"
consensus: "Integrated recommendation considering all viewpoints"
</npl-panel>
```

---

<!-- instructional: best-practice | level: 1 | labels: [quality, validation] -->
## Quality Assurance in Planning

### Reasoning Validation

| Check | Purpose |
|-------|---------|
| Logical Consistency | Ensure steps follow logically |
| Completeness | Verify all aspects addressed |
| Assumption Validation | Identify and verify assumptions |
| Alternative Consideration | Explore other approaches |

### Error Detection and Correction
- Identifying reasoning gaps
- Correcting logical errors
- Updating conclusions based on new information
- Learning from mistakes for future improvement

