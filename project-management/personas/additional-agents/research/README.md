# Research Agents

Agents focused on performance optimization, model tuning, cognitive load analysis, and evidence-based research.

## Agents

### npl-claude-optimizer
Optimizes Claude API usage, fine-tunes model selection, and maximizes performance within budget constraints. Manages prompt engineering and context efficiency.

### npl-cognitive-load-assessor
Measures cognitive complexity, identifies information overload points, and recommends simplification strategies. Ensures user-friendly design and documentation.

### npl-performance-monitor
Tracks system performance metrics, identifies optimization opportunities, and validates improvements. Maintains performance dashboards and SLI tracking.

### npl-research-validator
Gathers evidence, validates hypotheses, and conducts research-backed decision making. Ensures decisions are grounded in data and testing.

## Workflows

**Model & API Optimization**
1. npl-performance-monitor: Establish baseline metrics
2. npl-claude-optimizer: Identify optimization opportunities
3. npl-research-validator: Test improvements with hypothesis validation
4. npl-performance-monitor: Validate improvements at scale

**Cognitive Load Reduction**
1. npl-cognitive-load-assessor: Measure current cognitive load
2. npl-research-validator: Research best practices for domain
3. npl-cognitive-load-assessor: Propose simplifications
4. npl-research-validator: Validate improvements with users

## Integration Points

- **Upstream**: npl-thinker (hypothesis generation), npl-threat-modeler (security research)
- **Downstream**: npl-technical-writer (documentation clarity), tdd-coder (implementation)
- **Cross-functional**: npl-benchmarker (performance metrics), npl-user-researcher (user feedback)

## Key Responsibilities

| Agent | Primary | Secondary |
|-------|---------|-----------|
| **claude-optimizer** | API optimization, prompt engineering | Token efficiency, model selection |
| **cognitive-load-assessor** | Complexity measurement, simplification | Documentation clarity, UX analysis |
| **performance-monitor** | Metrics tracking, optimization identification | SLI management, alerting |
| **research-validator** | Hypothesis testing, evidence gathering | Best practice research, data analysis |

## Research Cycle

```
Hypothesis → Research → Measurement → Validation → Implementation → Monitoring
```

Research agents guide evidence-based decision making across feature development.
