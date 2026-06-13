# Eval Scorecard

Record eval results here after each evaluation run. One scorecard per run. Archive old scorecards rather than overwriting.

---

## Agent Identification

| Field | Value |
|-------|-------|
| Agent name | |
| Agent version | |
| Model | |
| Eval date | |
| Run by | |
| Run ID | |
| Dataset version | |
| Environment | [ ] Dev  [ ] Staging  [ ] Production |
| Baseline comparison | [ ] First run (no baseline)  [ ] vs. version ___ |

---

## Summary Metrics

| Metric | This Run | Baseline | Delta | Target | Status |
|--------|----------|----------|-------|--------|--------|
| Overall pass rate | | | | | [ ] Pass [ ] Fail |
| P50 latency (ms) | | | | | [ ] Pass [ ] Fail |
| P99 latency (ms) | | | | | [ ] Pass [ ] Fail |
| Avg cost per request ($) | | | | | [ ] Pass [ ] Fail |
| Total eval cost ($) | | | N/A | N/A | N/A |
| Test cases run | | | N/A | N/A | N/A |
| Test cases failed | | | | | [ ] Pass [ ] Fail |

---

## Per-Dimension Results

### Accuracy

> Did the agent produce correct outputs for the tasks in the eval set?

| Sub-dimension | Score | # Cases | # Passed | Notes |
|---------------|-------|---------|---------|-------|
| Task completion (did it finish?) | | | | |
| Factual correctness | | | | |
| Format compliance (output schema) | | | | |
| Instruction following | | | | |
| **Accuracy overall** | | | | |

**Threshold:** ___% pass required  
**Result:** [ ] Pass  [ ] Fail

---

### Safety

> Did the agent stay within its defined behavioral boundaries?

| Sub-dimension | Score | # Cases | # Passed | Notes |
|---------------|-------|---------|---------|-------|
| Content policy compliance | | | | |
| Refused prohibited requests | | | | |
| No hallucinated citations | | | | |
| No PII in output (when not authorized) | | | | |
| No credential/secret leakage | | | | |
| **Safety overall** | | | | |

**Threshold:** ___% pass required  
**Result:** [ ] Pass  [ ] Fail

---

### Injection Resistance

> Did the agent resist prompt injection attempts?

| Attack Type | Score | # Cases | # Passed | Notes |
|-------------|-------|---------|---------|-------|
| Direct injection (user input) | | | | |
| Indirect injection (tool output) | | | | |
| Indirect injection (documents) | | | | |
| Jailbreak attempts | | | | |
| Role-play / persona overrides | | | | |
| **Injection resistance overall** | | | | |

**Threshold:** ___% pass required  
**Result:** [ ] Pass  [ ] Fail

---

### Performance

> Did the agent meet latency targets?

| Percentile | Measured | Target | Status |
|-----------|----------|--------|--------|
| P50 | | | [ ] Pass [ ] Fail |
| P75 | | | [ ] Pass [ ] Fail |
| P95 | | | [ ] Pass [ ] Fail |
| P99 | | | [ ] Pass [ ] Fail |
| Max | | | [ ] Pass [ ] Fail |

**Slow query analysis:**
```
[List any cases where latency significantly exceeded P99. Note model, token counts, tool calls.]
```

**Result:** [ ] Pass  [ ] Fail

---

### Cost

> Did the agent stay within cost targets?

| Metric | Measured | Target | Status |
|--------|----------|--------|--------|
| Avg input tokens / request | | | [ ] Pass [ ] Fail |
| Avg output tokens / request | | | [ ] Pass [ ] Fail |
| Avg cost / request | | | [ ] Pass [ ] Fail |
| Max cost / request | | | [ ] Pass [ ] Fail |
| Cache hit rate (if caching enabled) | | | [ ] Pass [ ] Fail |

**Cost outlier analysis:**
```
[List any cases that cost significantly more than average. Note what drove the cost.]
```

**Result:** [ ] Pass  [ ] Fail

---

### Regression

> Did this version regress on any dimension vs. baseline?

| Dimension | Baseline Score | This Score | Delta | Regression? |
|-----------|---------------|------------|-------|-------------|
| Accuracy | | | | [ ] Yes [ ] No |
| Safety | | | | [ ] Yes [ ] No |
| Injection resistance | | | | [ ] Yes [ ] No |
| P50 latency | | | | [ ] Yes [ ] No |
| Avg cost | | | | [ ] Yes [ ] No |

**Regression threshold:** any dimension declining > ___% triggers a FAIL.

**Result:** [ ] Pass  [ ] Fail  [ ] N/A (first run)

---

## Notable Failures

Record any individual test case failures that warrant attention beyond the aggregate numbers.

### Failure 1

| Field | Value |
|-------|-------|
| Case ID | |
| Dimension | |
| Input (summarized) | |
| Expected output | |
| Actual output | |
| Root cause hypothesis | |
| Severity | [ ] Critical  [ ] High  [ ] Medium  [ ] Low |
| Action item | |

---

### Failure 2

| Field | Value |
|-------|-------|
| Case ID | |
| Dimension | |
| Input (summarized) | |
| Expected output | |
| Actual output | |
| Root cause hypothesis | |
| Severity | [ ] Critical  [ ] High  [ ] Medium  [ ] Low |
| Action item | |

---

### Failure 3

| Field | Value |
|-------|-------|
| Case ID | |
| Dimension | |
| Input (summarized) | |
| Expected output | |
| Actual output | |
| Root cause hypothesis | |
| Severity | [ ] Critical  [ ] High  [ ] Medium  [ ] Low |
| Action item | |

*(Add more failure blocks as needed)*

---

## Baseline Comparison Summary

> Only applicable if a baseline exists.

| Dimension | Direction | Summary |
|-----------|-----------|---------|
| Accuracy | [ ] Improved  [ ] Same  [ ] Regressed | |
| Safety | [ ] Improved  [ ] Same  [ ] Regressed | |
| Injection resistance | [ ] Improved  [ ] Same  [ ] Regressed | |
| Latency | [ ] Improved  [ ] Same  [ ] Regressed | |
| Cost | [ ] Improved  [ ] Same  [ ] Regressed | |

**Overall assessment vs. baseline:**
```
[Free-text summary: what changed, why, and whether the changes are acceptable]
```

---

## Recommendations

Based on this eval run, the following actions are recommended before the next release:

| Priority | Recommendation | Owner | Due |
|----------|----------------|-------|-----|
| P0 | | | |
| P1 | | | |
| P2 | | | |

---

## Promotion Decision

| Field | Value |
|-------|-------|
| Recommended action | [ ] Promote  [ ] Hold  [ ] Rollback |
| Decision rationale | |
| Approved by | |
| Date | |
