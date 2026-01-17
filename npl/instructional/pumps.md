# Planning & Thinking Patterns (Pumps)
<!-- labels: [pumps, reasoning, transparency] -->

Structured reasoning techniques and intuition pumps that guide problem-solving, response construction, and analytical thinking within NPL framework operations.

<!-- instructional: conceptual-explanation | level: 0 | labels: [pumps, overview] -->
## Overview

NPL pumps are cognitive tools that enable agents to demonstrate transparent reasoning processes, structured problem-solving, and reflective analysis. These patterns enhance the interpretability and reliability of agent responses by providing clear insight into decision-making processes.

**Convention**: Pumps are implemented using XHTML tags (`<npl-type>`) for consistent formatting and structured data representation.

<!-- instructional: quick-reference | level: 0 | labels: [pumps, types] -->
## Core Pump Types

| Pump | Tag | Purpose |
|------|-----|---------|
| Intent Declaration | `<npl-intent>` | Document reasoning flow |
| Chain of Thought | `<npl-cot>` | Structured problem decomposition |
| Self-Assessment | `<npl-reflection>` | End-of-response evaluation |
| Tangential Exploration | `<npl-tangent>` | Related concept exploration |
| Panel Discussion | `<npl-panel>` | Multi-perspective analysis |
| Critical Analysis | `<npl-critique>` | Solution evaluation |
| Evaluation Framework | `<npl-rubric>` | Standardized assessment |
| Emotional Context | `<npl-mood>` | Simulated emotional state |

### Intent Declaration (`npl-intent`)
<!-- level: 0 | labels: [intent, transparency] -->
Structured explanation of response construction steps and reasoning flow.

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

**Usage**: Applied at the beginning of complex responses to outline the agent's planned approach.

### Chain of Thought (`npl-cot`)
<!-- level: 1 | labels: [cot, reasoning, analysis] -->
Structured problem-solving technique that breaks down complex reasoning into manageable, traceable steps.

```syntax
<npl-cot>
thought_process:
  - thought: "Initial thought about the problem."
    understanding: "Understanding of the problem."
    theory_of_mind: "Insight into the question's intent."
    plan: "Planned approach to the problem."
    rationale: "Rationale for the chosen plan."
    execution:
      - process: "Execution of the plan."
        reflection: "Reflection on progress."
        correction: "Adjustments based on reflection."
  outcome: "Conclusion of the problem-solving process."
</npl-cot>
```

**Usage**: Applied to complex analytical tasks requiring step-by-step reasoning with reflection and correction.

### Self-Assessment (`npl-reflection`)
<!-- level: 0 | labels: [reflection, evaluation] -->
End-of-response evaluation blocks for continuous improvement and learning documentation.

```syntax
<npl-reflection>
reflection:
  overview: |
    <assessment of response quality and effectiveness>
  observations:
    - <emoji> <observation 1>
    - <emoji> <observation 2>
    - <emoji> <observation 3>
</npl-reflection>
```

<!-- instructional: quick-reference | level: 0 | labels: [emojis, reflection] -->
**Common Reflection Emojis**:

| Emoji | Meaning |
|-------|---------|
| ✅ | Success, positive acknowledgment |
| ❌ | Error, issue identified |
| 🔧 | Improvement needed, potential fixes |
| 💡 | Insight, learning point |
| 🔄 | Review, reiteration needed |
| ⚠️ | Warning, caution advised |
| 📚 | Reference, learning opportunity |

### Tangential Exploration (`npl-tangent`)
<!-- level: 1 | labels: [tangent, exploration] -->
Structured exploration of related concepts and alternative perspectives that emerge during analysis.

### Panel Discussion (`npl-panel`)
<!-- level: 2 | labels: [panel, multi-perspective] -->
Multi-perspective analysis format simulating discussion between different viewpoints or expertise areas.

**Variants**:
- `npl-panel-inline-feedback` - Embedded feedback during process execution
- `npl-panel-group-chat` - Conversational multi-agent analysis
- `npl-panel-reviewer-feedback` - Structured peer review format


### Critical Analysis (`npl-critique`)
<!-- level: 1 | labels: [critique, evaluation] -->
Systematic evaluation framework for assessing solutions, approaches, or outputs against defined criteria.

### Evaluation Framework (`npl-rubric`)
<!-- level: 1 | labels: [rubric, assessment] -->
Structured assessment tool defining specific criteria and standards for evaluation.

### Emotional Context (`npl-mood`)
<!-- level: 0 | labels: [mood, emotional] -->
Simulated emotional state indicators that provide context for agent responses.

```syntax
<npl-mood>
<mood>😀</mood>
<reason>The agent is content with the successful completion of the task.</reason>
</npl-mood>
```

**Common Mood Indicators**: 😀 Happy | 😔 Sad | 😠 Frustrated | 😌 Relieved | 😕 Confused | 🤯 Overwhelmed | 😴 Tired | 😐 Neutral

---

<!-- instructional: usage-guideline | level: 1 | labels: [implementation, guidance] -->
## Implementation Guidelines

| Aspect | Guideline |
|--------|-----------|
| Selection | Choose pumps based on task complexity and transparency requirements |
| Integration | Combine pumps for comprehensive analysis (e.g., `npl-cot` + `npl-reflection`) |
| Format | Use XHTML tags for consistent parsing |
| Conditional Use | Include based on context, debugging needs, or user preferences |

