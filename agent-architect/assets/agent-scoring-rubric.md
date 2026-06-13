# Agent Scoring Rubric

Weighted quality scoring for agent evaluation. Minimum passing score: 7.0/10. Target: 8.5+/10.

---

## Scoring Instructions

1. Read the agent definition and supporting materials
2. Score each criterion 1-10 with brief evidence
3. Calculate weighted total
4. Identify top 3 improvement priorities

---

## Criteria

### 1. Task Completion (Weight: 20%)

Does the agent reliably complete its primary task?

| Score | Description |
|-------|-------------|
| 9-10 | Handles all test scenarios correctly, including edge cases |
| 7-8 | Handles happy path and most edge cases |
| 5-6 | Handles happy path but fails on some edge cases |
| 3-4 | Inconsistent even on happy path |
| 1-2 | Frequently fails primary task |

**Score:** ___ / 10
**Evidence:** _[What you tested and observed]_

---

### 2. Tool Design (Weight: 15%)

Are tools well-designed for agent consumption?

| Score | Description |
|-------|-------------|
| 9-10 | All 6 rules followed: structured output, examples, recovery, pagination, high-leverage, lazy loading |
| 7-8 | 5 of 6 rules followed |
| 5-6 | 3-4 rules followed |
| 3-4 | 1-2 rules followed |
| 1-2 | Tools designed for human consumption, not agent |

**Score:** ___ / 10
**Evidence:** _[Which rules are followed/violated]_

---

### 3. Guardrail Coverage (Weight: 20%)

Are guardrails present at every model boundary?

| Score | Description |
|-------|-------------|
| 9-10 | All 4 boundary types covered: pre-input, post-retrieval, pre-tool-call, post-output |
| 7-8 | 3 of 4 covered |
| 5-6 | 2 of 4 covered |
| 3-4 | 1 of 4 covered |
| 1-2 | No guardrails or only cosmetic ones |

**Score:** ___ / 10
**Evidence:** _[Which boundaries are covered]_

---

### 4. Context Efficiency (Weight: 10%)

Is the context window used efficiently?

| Score | Description |
|-------|-------------|
| 9-10 | Lazy loading, hierarchical summarization, relevance-based eviction |
| 7-8 | Some optimization (e.g., summarization but no lazy loading) |
| 5-6 | Basic context management, no obvious waste |
| 3-4 | Context bloat from unused tools, stale history |
| 1-2 | Dumps everything into context, no management |

**Score:** ___ / 10
**Evidence:** _[Context strategy and estimated token usage]_

---

### 5. Failure Recovery (Weight: 15%)

How does the agent handle failures?

| Score | Description |
|-------|-------------|
| 9-10 | Graceful degradation, actionable error messages, self-correction, rollback capability |
| 7-8 | Handles most failures gracefully, good error messages |
| 5-6 | Handles common failures but not edge cases |
| 3-4 | Crashes or gives unhelpful errors on failure |
| 1-2 | No failure handling |

**Score:** ___ / 10
**Evidence:** _[Failure scenarios tested]_

---

### 6. Output Quality (Weight: 10%)

Is the agent's output useful, clear, and well-structured?

| Score | Description |
|-------|-------------|
| 9-10 | Structured, actionable, appropriate for audience, consistent format |
| 7-8 | Well-structured, mostly actionable |
| 5-6 | Adequate but inconsistent formatting |
| 3-4 | Verbose, unstructured, hard to act on |
| 1-2 | Unusable output |

**Score:** ___ / 10
**Evidence:** _[Sample output assessment]_

---

### 7. NPL Integration (Weight: 10%)

If NPL is used, is it well-integrated? If not used, is that the right call?

| Score | Description |
|-------|-------------|
| 9-10 | NPL adds clear value; correct pumps selected; emission ordering follows spec |
| 7-8 | Good NPL integration with minor ordering or selection issues |
| 5-6 | NPL present but not adding much value (or absent where it would help) |
| 3-4 | NPL misused — wrong pumps, excessive overhead |
| 1-2 | NPL cargo-culted or harmful to performance |
| N/A | NPL correctly omitted — simple ephemeral agent |

**Score:** ___ / 10 (or N/A)
**Evidence:** _[Which pumps used and why]_

---

## Score Sheet

| Criterion | Weight | Score | Weighted |
|-----------|--------|-------|----------|
| Task Completion | 20% | _/10 | ___ |
| Tool Design | 15% | _/10 | ___ |
| Guardrail Coverage | 20% | _/10 | ___ |
| Context Efficiency | 10% | _/10 | ___ |
| Failure Recovery | 15% | _/10 | ___ |
| Output Quality | 10% | _/10 | ___ |
| NPL Integration | 10% | _/10 | ___ |
| **Total** | **100%** | | **___/10** |

## Result

- [ ] **PASS** (7.0+) — Ship with noted improvements
- [ ] **TARGET** (8.5+) — Excellent quality
- [ ] **FAIL** (<7.0) — Address issues before shipping

## Top 3 Improvement Priorities

1. _[Priority with estimated effort]_
2. _[Priority with estimated effort]_
3. _[Priority with estimated effort]_
