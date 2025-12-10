# npl-risk-monitor

Continuous risk assessment specialist for proactive project health monitoring.

## Purpose

Transforms reactive risk management into proactive prevention. Identifies risks across technical, adoption, resource, and timeline dimensions before impact occurs.

## Capabilities

- Identify and classify risks across four dimensions (technical, adoption, resource, timeline)
- Monitor risk indicator trends and threshold breaches
- Track mitigation strategy effectiveness
- Provide predictive escalation timelines and health scoring
- Generate stakeholder-appropriate communications

See [Capabilities](npl-risk-monitor.detailed.md#capabilities) for full details.

## Usage

```bash
# Initial assessment
@npl-risk-monitor "Conduct initial risk assessment for project X"

# Continuous monitoring
@npl-risk-monitor "Analyze current risk status and emerging threats"

# Category-specific analysis
@npl-risk-monitor "Assess technical implementation risks for microservices migration"

# Mitigation evaluation
@npl-risk-monitor "Evaluate effectiveness of current mitigation strategies"
```

See [Usage Examples](npl-risk-monitor.detailed.md#usage-examples) for detailed scenarios.

## Risk Scoring

Priority calculated as: `Impact (1-4) x Probability (1-4) = Priority (1-16)`

| Score | Severity | Response |
|:------|:---------|:---------|
| 12-16 | Critical | Immediate escalation |
| 8-11 | High | Active mitigation |
| 4-7 | Medium | Monitor |
| 1-3 | Low | Log |

See [Risk Assessment Framework](npl-risk-monitor.detailed.md#risk-assessment-framework) for complete matrix.

## Integration

```bash
# Risk-driven technical review
@npl-risk-monitor "Identify technical risks" && @npl-technical-reality-checker "Validate feasibility"

# User adoption assessment
@npl-risk-monitor "Assess adoption risks" && @npl-user-impact-assessor "Develop mitigation"

# Project coordination
@npl-risk-monitor "Critical timeline risk" && @npl-project-coordinator "Adjust plan"
```

See [Integration Patterns](npl-risk-monitor.detailed.md#integration-patterns) for pipeline examples.

## Success Metrics

| Metric | Target |
|:-------|:-------|
| Early Detection | >85% |
| Mitigation Success | >75% |
| False Positives | <15% |

## See Also

- Detailed documentation: [npl-risk-monitor.detailed.md](npl-risk-monitor.detailed.md)
- Agent conventions: `npl/agent.md`
