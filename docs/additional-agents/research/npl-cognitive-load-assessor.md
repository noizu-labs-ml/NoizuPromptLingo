# npl-cognitive-load-assessor

UX complexity analysis agent for cognitive load measurement, learning curve assessment, and adoption barrier identification.

```bash
@npl-cognitive-load-assessor <command> [options]
```

## Commands

| Command | Description |
|:--------|:------------|
| `analyze` | Comprehensive cognitive load assessment |
| `learning-curve` | Time-to-proficiency analysis |
| `barriers` | Adoption barrier identification |
| `learning-path` | Generate personalized learning plans |
| `accessibility-audit` | WCAG compliance validation |

See [npl-cognitive-load-assessor.detailed.md](./npl-cognitive-load-assessor.detailed.md) for full command reference.

## Quick Start

```bash
# Cognitive load assessment
@npl-cognitive-load-assessor analyze --target=npl-interface

# Learning curve for user profile
@npl-cognitive-load-assessor learning-curve --user-profile="programmer,no-ai-experience"

# Identify adoption barriers
@npl-cognitive-load-assessor barriers --scope=onboarding --generate-solutions

# Generate learning path
@npl-cognitive-load-assessor learning-path --goal="custom-agent-development" --time-budget="10-hours"

# Accessibility audit
@npl-cognitive-load-assessor accessibility-audit --standards="WCAG-2.2-AAA"
```

## Cognitive Load Theory

Applies Sweller's Cognitive Load Theory measuring three load types:

| Type | Definition | Target |
|:-----|:-----------|:-------|
| Intrinsic | Essential task complexity | 40-50% |
| Extraneous | Unnecessary design burden | 10-20% |
| Germane | Productive learning effort | 30-40% |

See [Cognitive Load Theory Framework](./npl-cognitive-load-assessor.detailed.md#cognitive-load-theory-framework) for details.

## NASA-TLX Metrics

Modified NASA Task Load Index with five dimensions: Mental Demand, Temporal Demand, Performance, Effort, Frustration. Scale 1-10.

See [NASA-TLX Adaptation](./npl-cognitive-load-assessor.detailed.md#nasa-tlx-adaptation) for baseline comparisons.

## Learning Stages

| Stage | Timeline | Dropout Risk |
|:------|:---------|:-------------|
| Basic Comprehension | Week 1-2 | 35% |
| Functional Application | Week 3-6 | 15% |
| Advanced Integration | Week 7-12 | 5% |
| Expertise | Month 4+ | 5% |

See [Learning Curve Model](./npl-cognitive-load-assessor.detailed.md#learning-curve-model) for velocity factors.

## Workflow Integration

```bash
# Combined UX analysis
@npl-cognitive-load-assessor analyze && @npl-grader evaluate --rubric=cognitive-standards.md

# Optimization with validation
@npl-claude-optimizer optimize && @npl-cognitive-load-assessor quantify --context=optimization
```

## Success Metrics

| Metric | Target |
|:-------|:-------|
| Cognitive load (intermediate tasks) | <6/10 |
| Learning curve reduction | >40% |
| Adoption barrier reduction | >50% |
| Accessibility compliance | WCAG 2.2 AAA |
| First-month dropout rate | <20% |

See [Success Metrics](./npl-cognitive-load-assessor.detailed.md#success-metrics) for full list.

## See Also

- [Detailed Reference](./npl-cognitive-load-assessor.detailed.md) - Complete documentation
- [Additional Agents README](../README.md) - Agent library overview
- Core definition: `core/additional-agents/research/npl-cognitive-load-assessor.md`
