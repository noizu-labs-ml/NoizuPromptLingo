# Model Comparison Guide

## Overview

The same skill can perform dramatically differently across models. This guide covers methodology for fair, meaningful cross-model comparison.

## Experimental Design

### Controls

When comparing models, control for everything *except* the model:

| Variable | Control Method |
|----------|---------------|
| Temperature | Fix at same value (recommend 0.3 for deterministic-ish eval) |
| System prompt | Identical SKILL.md loaded for all models |
| Context window | Standardize input length; trim if needed |
| Tool availability | Same tool set for all models |
| Evaluation rubric | Same scorer, same thresholds |
| Scenario order | Randomize to avoid order effects |

### Sample Size

| Scope | Recommended Runs |
|-------|------------------|
| Quick smoke test | 3 scenarios, 10 MC questions |
| Standard comparison | All scenarios, full exam battery |
| Publication-grade | 3× repetition per model, statistical significance testing |

### Metrics for Comparison

| Metric | What It Shows |
|--------|--------------|
| Overall score | General capability gap |
| Dimension-by-dimension | Specific strengths/weaknesses |
| Scenario pass rate | Practical reliability |
| Recovery success rate | Robustness |
| MC by difficulty | Where models diverge |
| Essay rubric breakdown | Reasoning vs. knowledge gaps |
| Token efficiency | Cost/performance trade-off |

## Comparison Matrix

Generate a model × dimension matrix:

```markdown
| Dimension | Opus | Sonnet | Haiku | Max Delta |
|-----------|------|--------|-------|-----------|
| Task Accuracy | 0.92 | 0.85 | 0.70 | 0.22 |
| Flow Adherence | 0.90 | 0.88 | 0.75 | 0.15 |
| Recovery Ability | 0.85 | 0.70 | 0.50 | 0.35 |
| Edge Case Handling | 0.80 | 0.72 | 0.55 | 0.25 |
| Instruction Following | 0.90 | 0.85 | 0.78 | 0.12 |
| Self Containment | 0.95 | 0.92 | 0.88 | 0.07 |
| Cross Reference | 0.88 | 0.82 | 0.70 | 0.18 |
| **Overall** | **0.88** | **0.81** | **0.69** | **0.19** |
```

## Analysis Patterns

### Pattern 1: Uniform Gap
All dimensions are ~X points lower for the weaker model. This suggests the skill works but the weaker model lacks general capability. **Recommendation**: Skill is portable; lower models will just perform proportionally worse.

### Pattern 2: Specific Weakness
One dimension is disproportionately low for a model. E.g., Haiku scores 0.50 on recovery but 0.85 on flow adherence. **Recommendation**: Skill depends on a capability the model lacks. Consider simplifying recovery logic for smaller models.

### Pattern 3: Cross-Over
Model A excels at dimension X but Model B excels at dimension Y. **Recommendation**: The skill exercises different model strengths. Document which model is recommended for which use case.

### Pattern 4: Floor Effect
A model scores near 0 on a dimension. **Recommendation**: The skill requires capabilities beyond this model's range. Declare minimum model requirement.

## Reporting

### Model Comparison Report Template

```markdown
## Model Comparison: {skill-name}

### Executive Summary
- Best overall: {model} ({score})
- Most cost-effective: {model} ({score} at ${cost}/eval)
- Minimum viable: {model} ({score})

### Dimension Analysis
{comparison matrix}

### Scenario Outcomes
| Scenario | Opus | Sonnet | Haiku |
|----------|------|--------|-------|
| {scenario} | {pass/fail} ({score}) | ... | ... |

### Key Findings
1. {finding with evidence}
2. {finding with evidence}
3. {finding with evidence}

### Skill Design Implications
- {change that would improve cross-model performance}
- {capability that should be documented as model-dependent}

### Recommended Configuration
- **Primary model**: {model} — {reason}
- **Fallback model**: {model} — {reason}
- **Budget option**: {model} — {reason} (caveats: {list})
```
