# npl-risk-monitor - Detailed Documentation

Continuous risk assessment specialist for proactive project health monitoring.

## Overview

The `npl-risk-monitor` agent transforms reactive risk management into proactive risk prevention. It identifies risks across technical, adoption, resource, and timeline dimensions before impact occurs, maintaining comprehensive risk awareness throughout project lifecycles.

**Agent Type**: Service agent
**NPL Version**: 1.0
**Aliases**: `@risk-monitor`, `@npl-risk-monitor`

## Capabilities

### Risk Identification

The agent detects and classifies risks across four primary dimensions:

| Dimension | Focus Areas |
|:----------|:------------|
| Technical | Architecture flaws, integration failures, performance bottlenecks, security vulnerabilities |
| User Adoption | Training gaps, UX friction, change resistance, accessibility barriers |
| Resource | Skill shortages, budget constraints, tooling limitations, vendor dependencies |
| Timeline | Scope creep, dependency delays, approval bottlenecks, external blockers |

### Continuous Monitoring

- Tracks risk indicator trends over time
- Detects threshold breaches automatically
- Monitors mitigation strategy effectiveness
- Identifies emerging risks from pattern analysis

### Predictive Analysis

- Calculates risk escalation timelines
- Projects cascade effects across dependencies
- Generates health scores for stakeholder reporting
- Estimates probability-adjusted impact windows

### Communication

- Generates stakeholder-appropriate reports by severity level
- Produces executive summaries for high-priority risks
- Creates technical deep-dives for implementation teams
- Maintains risk registers with audit trails

## Risk Assessment Framework

### Scoring Matrix

Risk priority calculated as: `Impact (1-4) x Probability (1-4) = Priority (1-16)`

| Score Range | Severity | Response |
|:------------|:---------|:---------|
| 12-16 | Critical | Immediate escalation, daily tracking |
| 8-11 | High | Active mitigation, weekly review |
| 4-7 | Medium | Monitor, monthly assessment |
| 1-3 | Low | Log and archive |

### Impact Levels

| Level | Definition |
|:------|:-----------|
| 4 - Severe | Project failure, major budget overrun, regulatory violation |
| 3 - Major | Significant delay, scope reduction, stakeholder escalation |
| 2 - Moderate | Workaround required, minor delay, increased cost |
| 1 - Minor | Inconvenience, no material impact |

### Probability Levels

| Level | Definition |
|:------|:-----------|
| 4 - Almost Certain | >90% likelihood |
| 3 - Likely | 60-90% likelihood |
| 2 - Possible | 30-60% likelihood |
| 1 - Unlikely | <30% likelihood |

## Usage Examples

### Initial Assessment

```bash
@npl-risk-monitor "Conduct initial risk assessment for project X"
```

Output includes:
- Risk inventory by category
- Priority-ranked risk list
- Recommended mitigation strategies
- Monitoring schedule

### Continuous Monitoring

```bash
@npl-risk-monitor "Analyze current risk status and emerging threats"
```

Output includes:
- Risk status changes since last assessment
- New risks identified
- Threshold breaches
- Mitigation effectiveness metrics

### Category-Specific Analysis

```bash
@npl-risk-monitor "Assess technical implementation risks for microservices migration"
```

Focuses on:
- Architecture risks
- Integration points
- Performance concerns
- Security implications

### Mitigation Evaluation

```bash
@npl-risk-monitor "Evaluate effectiveness of current mitigation strategies"
```

Reports on:
- Strategy implementation status
- Effectiveness measurements
- Adjustment recommendations
- Resource allocation efficiency

### Stakeholder Reporting

```bash
@npl-risk-monitor "Generate executive risk summary for steering committee"
```

Produces:
- High-level risk dashboard
- Key metrics and trends
- Action items requiring decisions
- Budget/timeline impact projections

## Integration Patterns

### With Technical Review

```bash
@npl-risk-monitor "Identify technical implementation risks" \
  && @npl-technical-reality-checker "Validate feasibility considering risks"
```

Risk findings inform feasibility assessment.

### With User Impact Analysis

```bash
@npl-risk-monitor "Assess user adoption risks" \
  && @npl-user-impact-assessor "Develop mitigation strategies"
```

Adoption risks drive user experience improvements.

### With Project Coordination

```bash
@npl-risk-monitor "Critical timeline risk detected" \
  && @npl-project-coordinator "Adjust project plan to mitigate risk"
```

Risk triggers feed into project planning.

### Multi-Agent Risk Pipeline

```bash
@npl-requirements-analyzer "Extract dependencies" \
  | @npl-risk-monitor "Assess dependency risks" \
  | @npl-project-coordinator "Plan contingencies"
```

## Output Formats

### Risk Register Entry

```yaml
risk_id: RISK-2024-0042
title: Third-party API rate limiting
category: technical
status: active
impact: 3
probability: 2
priority: 6
owner: integration-team
identified: 2024-01-15
mitigation:
  strategy: Implement caching layer
  status: in_progress
  due: 2024-02-01
triggers:
  - API response time >500ms
  - Rate limit warnings in logs
next_review: 2024-01-22
```

### Health Score Dashboard

```
Project Health: 72/100 (Moderate Concern)

Risk Distribution:
  Critical: 0
  High: 2
  Medium: 5
  Low: 8

Trend: Improving (was 65 last week)

Top Concerns:
  1. [HIGH] Database migration timeline
  2. [HIGH] Key resource availability
```

## Configuration Options

### Runtime Flags

| Flag | Default | Description |
|:-----|:--------|:------------|
| `@risk-threshold-critical` | 12 | Minimum score for critical classification |
| `@risk-threshold-high` | 8 | Minimum score for high classification |
| `@auto-escalate` | true | Automatically notify on critical risks |
| `@tracking-interval` | daily | Assessment frequency |

### Work Log Modes

Follows standard agent work logging (see `npl/agent.md#agent-work-logging`):

| Mode | Output |
|:-----|:-------|
| `standard` | Summary + detailed markdown files |
| `verbose` | Adds YAML structured data |
| `yaml|summary` | Machine-readable + brief overview |

## Success Metrics

Target performance indicators:

| Metric | Target | Description |
|:-------|:-------|:------------|
| Early Detection Rate | >85% | Risks identified before impact |
| Mitigation Success Rate | >75% | Mitigations that prevent impact |
| False Positive Rate | <15% | Risks that don't materialize |
| Response Time | <24h | Time from detection to assessment |

## Best Practices

### Assessment Frequency

- **Initial**: Full assessment at project kickoff
- **Weekly**: High and critical risk review
- **Bi-weekly**: Complete portfolio review
- **On-demand**: Triggered by significant changes

### Risk Communication

- Match detail level to audience
- Lead with action items, not analysis
- Quantify impact in business terms
- Track and report on prediction accuracy

### Integration Points

- Feed into sprint planning for mitigation tasks
- Connect to incident management for realized risks
- Link to decision logs for risk-based choices
- Archive for post-mortem analysis

## Limitations

- Relies on accurate input data quality
- Cannot predict black swan events
- Effectiveness depends on honest stakeholder input
- Requires regular calibration against outcomes
- Does not replace domain expert judgment

## Related Agents

| Agent | Relationship |
|:------|:-------------|
| `@npl-technical-reality-checker` | Validates technical feasibility |
| `@npl-user-impact-assessor` | Analyzes adoption barriers |
| `@npl-project-coordinator` | Incorporates risks into planning |
| `@npl-requirements-analyzer` | Identifies dependency risks |
| `@npl-progress-tracker` | Monitors mitigation task completion |

## File References

- Agent definition conventions: `npl/agent.md`
- Work logging: `npl/agent.md#agent-work-logging`
- Session tracking: `npl/agent.md#agent-session-tracking`
