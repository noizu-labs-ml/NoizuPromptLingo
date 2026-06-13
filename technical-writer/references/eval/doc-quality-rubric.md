# Documentation Quality Rubric

Scoring rubric for evaluating technical documentation quality. Use during proof editing, doc audits, and quality gates.

## Scoring Scale

| Score | Meaning |
|-------|---------|
| 1-2 | **Poor** — Missing or actively misleading |
| 3-4 | **Below average** — Present but has significant issues |
| 5-6 | **Adequate** — Gets the job done, room for improvement |
| 7-8 | **Good** — Solid quality, minor issues |
| 9-10 | **Excellent** — Exemplary, could be used as a reference |

## Criteria

### 1. Accuracy (Weight: 25%)

Does the documentation match reality?

| Score | Description |
|-------|-------------|
| 1-2 | Code examples don't run; commands use wrong flags; describes features that don't exist |
| 3-4 | Most examples work but some are outdated; minor inaccuracies in descriptions |
| 5-6 | Examples work; descriptions are mostly correct; some version-specific details missing |
| 7-8 | All examples verified; accurate descriptions; version-appropriate |
| 9-10 | Tested against current version; edge cases noted; errors documented with fixes |

**Evidence to check:** Run code examples. Verify CLI flags against `--help`. Check file paths exist. Test URLs.

### 2. Completeness (Weight: 20%)

Does it cover what the reader needs?

| Score | Description |
|-------|-------------|
| 1-2 | Only covers one use case; major sections missing |
| 3-4 | Primary use case covered; secondary use cases missing; no troubleshooting |
| 5-6 | Common use cases covered; some gaps in edge cases; basic troubleshooting |
| 7-8 | Comprehensive coverage; troubleshooting section; configuration reference |
| 9-10 | All use cases including edge cases; complete error documentation; migration guides |

**Evidence to check:** Gap analysis against expected sections for doc type. Reader journey coverage.

### 3. Clarity (Weight: 20%)

Can the reader understand it on first read?

| Score | Description |
|-------|-------------|
| 1-2 | Dense prose; undefined jargon; ambiguous instructions |
| 3-4 | Some clear sections; inconsistent clarity; occasional jargon without definition |
| 5-6 | Generally readable; some sentences need re-reading; jargon mostly defined |
| 7-8 | Clear throughout; good use of examples; scannable structure |
| 9-10 | Crystal clear; every concept illustrated; progressive disclosure; perfect scannability |

**Evidence to check:** Readability score. Paragraph length. Jargon audit. Header density.

### 4. Structure (Weight: 15%)

Is the information well-organized?

| Score | Description |
|-------|-------------|
| 1-2 | No clear organization; wall of text; no headers |
| 3-4 | Some headers but inconsistent levels; information in wrong sections |
| 5-6 | Logical section order; headers present; some navigation issues |
| 7-8 | Clear hierarchy; progressive disclosure; good use of tables and lists |
| 9-10 | Perfect information architecture; every section in the right place; excellent navigation |

**Evidence to check:** Header hierarchy. Section ordering. Cross-references. Table of contents coverage.

### 5. Examples (Weight: 10%)

Are examples present, relevant, and helpful?

| Score | Description |
|-------|-------------|
| 1-2 | No examples; or examples that don't work |
| 3-4 | Few examples; some use lorem ipsum or unrealistic data |
| 5-6 | Examples for main concepts; realistic data; missing expected output |
| 7-8 | Examples for all concepts with expected output; realistic scenarios |
| 9-10 | Examples + counter-examples; edge cases shown; copy-pasteable and tested |

**Evidence to check:** Example count vs. concept count. Realism of example data. Output shown.

### 6. Freshness (Weight: 10%)

Is the documentation current?

| Score | Description |
|-------|-------------|
| 1-2 | References deprecated features; screenshots from old UI; wrong version |
| 3-4 | Mostly current but some stale sections; version not stated |
| 5-6 | Current for the latest major version; minor details may be stale |
| 7-8 | Updated within one release cycle; version clearly stated |
| 9-10 | Updated with every release; changelog maintained; deprecation notices current |

**Evidence to check:** `git log` on doc file vs. related source files. Version references. Screenshot currency.

## Scoring Template

```markdown
## Quality Score: {Document Name}

**Date:** {date}
**Reviewer:** {name/agent}
**Document type:** {onboarding | API | README | runbook | other}

| Criterion | Weight | Score | Weighted |
|-----------|--------|-------|----------|
| Accuracy | 25% | {n}/10 | {w} |
| Completeness | 20% | {n}/10 | {w} |
| Clarity | 20% | {n}/10 | {w} |
| Structure | 15% | {n}/10 | {w} |
| Examples | 10% | {n}/10 | {w} |
| Freshness | 10% | {n}/10 | {w} |
| **Total** | **100%** | | **{total}/10** |

### Evidence
- Accuracy: {what was verified}
- Completeness: {what gaps were found}
- Clarity: {readability observations}
- Structure: {organization assessment}
- Examples: {example quality notes}
- Freshness: {currency assessment}

### Recommendations
1. {Highest-impact improvement}
2. {Second priority}
3. {Third priority}
```

## Quality Thresholds

| Threshold | Score | Meaning |
|-----------|-------|---------|
| **Ship-ready** | 7.0+ | Safe to publish; iterate later |
| **Needs work** | 5.0-6.9 | Functional but has notable gaps |
| **Don't publish** | < 5.0 | Will actively harm the reader's experience |

## Quick Quality Check (2-Minute Version)

For fast triage when you don't need a full rubric:

- [ ] Does the first paragraph explain what this is?
- [ ] Can you copy-paste the first code example and run it?
- [ ] Is there a troubleshooting section?
- [ ] Are all links valid?
- [ ] Was it updated in the last 90 days?

**3+ checks = probably adequate. <3 = needs attention.**
