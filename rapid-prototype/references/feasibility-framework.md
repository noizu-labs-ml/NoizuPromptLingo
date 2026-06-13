# Feasibility Framework

Deep dive on the six evaluation dimensions, scoring calibration, and edge cases for prototype evaluation.

## The Six Dimensions

### 1. Technical Feasibility

**Question:** Does the core concept actually work?

| Score | Meaning | Example |
|-------|---------|---------|
| 5 | Works perfectly as expected | API returns correct data, algorithm produces right output |
| 4 | Works with minor workarounds | Needed to transform data format, but functionally correct |
| 3 | Partially works, gaps identified | Core function works but discovered a missing capability |
| 2 | Barely works, major gaps | Only works under narrow conditions |
| 1 | Does not work | Fundamental limitation discovered |

### 2. Performance

**Question:** Is it fast/efficient enough for the intended use case?

| Score | Meaning | Example |
|-------|---------|---------|
| 5 | Exceeds requirements | Response time well under threshold |
| 4 | Meets requirements | Within acceptable range |
| 3 | Borderline | Acceptable for MVP, needs optimization for scale |
| 2 | Below requirements | Noticeable lag, may frustrate users |
| 1 | Unacceptable | Order-of-magnitude too slow, or memory/CPU explosion |

**Note:** Score against the actual use case, not abstract ideals. A 2-second response for a batch job is fine; for a UI interaction it's a 2.

### 3. Complexity

**Question:** How hard is the production version?

| Score | Meaning | Estimated Production Effort |
|-------|---------|----------------------------|
| 5 | Trivial | Days — clean up the prototype and ship it |
| 4 | Manageable | 1-2 weeks with known techniques |
| 3 | Moderate | 2-4 weeks, some unknowns remain |
| 2 | High | Months, significant architecture work |
| 1 | Extreme | The prototype proves it's possible but the production version is a different beast entirely |

### 4. Integration

**Question:** Does it play well with existing systems?

| Score | Meaning | Example |
|-------|---------|---------|
| 5 | Drop-in compatible | Uses same auth, data formats, conventions |
| 4 | Minor adaptation needed | Needs a thin adapter layer |
| 3 | Moderate integration work | Different paradigm but bridgeable |
| 2 | Significant friction | Conflicting assumptions, data model mismatch |
| 1 | Incompatible | Would require rewriting existing systems |

### 5. Maintainability

**Question:** Will this be a nightmare to maintain?

| Score | Meaning | Example |
|-------|---------|---------|
| 5 | Self-evident | Well-documented library, active community, simple model |
| 4 | Standard | Follows common patterns, team has expertise |
| 3 | Manageable | Some learning curve, adequate docs |
| 2 | Concerning | Poor docs, niche technology, bus-factor risk |
| 1 | Nightmare | Undocumented, abandoned, or black-box behavior |

### 6. Dependencies

**Question:** Are the required libraries/services/APIs reliable?

| Score | Meaning | Example |
|-------|---------|---------|
| 5 | Rock solid | Major OSS project, well-funded SaaS, or standard library |
| 4 | Reliable | Active maintenance, good track record |
| 3 | Adequate | Maintained but with caveats (small team, niche) |
| 2 | Risky | Infrequent updates, unclear roadmap, single maintainer |
| 1 | Dangerous | Abandoned, deprecated, or vendor lock-in with no exit |

## Scoring Calibration Tips

- **Don't inflate.** A 3 is the realistic middle — "probably fine but not certain." Most honest evaluations cluster around 3-4.
- **Use evidence.** Each score should reference something observed during the spike, not a feeling.
- **Score independently.** Don't let a high score on one dimension pull up others.
- **Consider production, not prototype.** The prototype can be ugly — score based on what the production version would require.

## Edge Cases

### The Prototype Works But You Have a Bad Feeling

Trust the feeling but demand specifics. If you can't articulate the concern, it's probably one of:
- Complexity (the happy path worked but edge cases will be brutal)
- Dependencies (the library worked but the docs/community worry you)
- Integration (it works standalone but plugging it in will be painful)

Score the specific dimension lower and document why.

### The Prototype Failed But the Idea Is Still Good

Separate concept feasibility from implementation feasibility. If the prototype failed because of a bad approach (wrong library, wrong architecture) but the underlying concept is sound:
- Score technical feasibility based on what you learned
- Add a "pivot recommendation" to the report: "No-go on this approach; recommend re-spiking with [alternative]"

### Multiple Stakeholder Perspectives

Different roles weight dimensions differently:

| Stakeholder | Weights Heavily | Cares Less About |
|-------------|-----------------|-------------------|
| Engineering lead | Complexity, Maintainability | Performance (can optimize later) |
| Product manager | Technical Feasibility, Performance | Complexity (that's engineering's problem) |
| CTO/Architect | Integration, Dependencies | Performance (can optimize later) |
| Security | Dependencies, Integration | Complexity |

When producing the report, note which perspective drove the recommendation.

## Incomplete Evaluations

Sometimes the spike doesn't produce enough evidence to score a dimension. This is fine — mark it as "N/A (insufficient evidence)" and explain what additional spike work would be needed to score it.

A report with two N/A dimensions is still useful. A report with four N/A dimensions means the spike was too narrow — consider extending the timebox.
