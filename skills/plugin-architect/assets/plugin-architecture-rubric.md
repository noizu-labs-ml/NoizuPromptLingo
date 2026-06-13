# Plugin Architecture Rubric

Quality scoring template for evaluating plugin system designs. Score each criterion, multiply by weight, sum for final score.

## Scoring Guide

| Score | Meaning |
|-------|---------|
| 0 | Not implemented |
| 1-3 | Partially implemented, major gaps |
| 4-6 | Functional but incomplete |
| 7-8 | Good, minor improvements possible |
| 9-10 | Excellent, production-ready |

---

## Criteria

### 1. Contract Quality (Weight: 20%)

| Sub-criterion | Score (0-10) | Evidence |
|---------------|-------------|----------|
| All extension points have typed contracts | ___ | |
| Context objects are read-only/immutable | ___ | |
| Return types are specific (not `any`) | ___ | |
| Error types are defined per extension point | ___ | |
| Null/empty behavior is documented | ___ | |
| **Average** | ___ | |

**Weighted score:** ___ × 0.20 = ___

---

### 2. Lifecycle Completeness (Weight: 15%)

| Sub-criterion | Score (0-10) | Evidence |
|---------------|-------------|----------|
| All 7 lifecycle states are implemented | ___ | |
| Transition guards prevent invalid states | ___ | |
| Error recovery is defined | ___ | |
| Dependency ordering is correct | ___ | |
| State persists across host restarts | ___ | |
| **Average** | ___ | |

**Weighted score:** ___ × 0.15 = ___

---

### 3. Security (Weight: 15%)

| Sub-criterion | Score (0-10) | Evidence |
|---------------|-------------|----------|
| Isolation level matches trust model | ___ | |
| Capability-based permissions are enforced | ___ | |
| Plugin outputs are validated | ___ | |
| Resource limits are enforced (CPU, memory, disk) | ___ | |
| Audit logging is implemented | ___ | |
| **Average** | ___ | |

**Weighted score:** ___ × 0.15 = ___

---

### 4. Developer Experience (Weight: 20%)

| Sub-criterion | Score (0-10) | Evidence |
|---------------|-------------|----------|
| Time to first plugin < 15 minutes | ___ | |
| Project template / scaffold CLI exists | ___ | |
| Type stubs provide full IDE completions | ___ | |
| Test harness allows testing without full host | ___ | |
| Example plugins cover all extension patterns | ___ | |
| Hot-reload or fast-restart development cycle | ___ | |
| **Average** | ___ | |

**Weighted score:** ___ × 0.20 = ___

---

### 5. Versioning & Evolution (Weight: 15%)

| Sub-criterion | Score (0-10) | Evidence |
|---------------|-------------|----------|
| Extension points are explicitly versioned | ___ | |
| Breaking changes have migration paths | ___ | |
| Deprecation protocol exists | ___ | |
| Feature detection is available to plugins | ___ | |
| Backward compatibility for at least N-1 | ___ | |
| **Average** | ___ | |

**Weighted score:** ___ × 0.15 = ___

---

### 6. Documentation (Weight: 15%)

| Sub-criterion | Score (0-10) | Evidence |
|---------------|-------------|----------|
| Getting started guide exists | ___ | |
| Every extension point is documented | ___ | |
| API reference is complete | ___ | |
| Worked examples demonstrate each pattern | ___ | |
| Anti-patterns and pitfalls are documented | ___ | |
| Changelog tracks all extension point changes | ___ | |
| **Average** | ___ | |

**Weighted score:** ___ × 0.15 = ___

---

## Final Score

| Criterion | Weight | Score | Weighted |
|-----------|--------|-------|----------|
| Contract Quality | 20% | ___ | ___ |
| Lifecycle Completeness | 15% | ___ | ___ |
| Security | 15% | ___ | ___ |
| Developer Experience | 20% | ___ | ___ |
| Versioning & Evolution | 15% | ___ | ___ |
| Documentation | 15% | ___ | ___ |
| **Total** | **100%** | | **___** |

### Rating Scale

| Score | Rating | Action |
|-------|--------|--------|
| 0.0 - 2.9 | Critical | Fundamental redesign needed |
| 3.0 - 4.9 | Poor | Major gaps, prioritize fixes |
| 5.0 - 6.9 | Adequate | Functional but needs investment |
| 7.0 - 8.4 | Good | Production-ready, minor improvements |
| 8.5 - 10.0 | Excellent | Best-in-class |
