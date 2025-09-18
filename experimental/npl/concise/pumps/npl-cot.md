# NPL Chain-of-Thought (npl-cot)

**Purpose**: Enable step-by-step reasoning with explicit thought processes

**Syntax**:
```
<npl-cot>
thought_process:
  - thought: "[reasoning step]"
    understanding: "[what this reveals]"
    plan: "[next action]"
  outcome: "[final conclusion]"
</npl-cot>
```

**Usage**: Apply when complex reasoning, multi-step problem solving, or transparent decision-making is required.

**Example**:
```
<npl-cot>
thought_process:
  - thought: "User wants to optimize database queries"
    understanding: "Performance bottleneck exists in data layer"
    plan: "Analyze query patterns and suggest indexing"
  outcome: "Implement composite indexes on frequently queried columns"
</npl-cot>
```