# npl-risk-monitor

Continuous risk assessment specialist that identifies project risks early, tracks mitigation effectiveness, and provides early warning systems for project health monitoring.

## Purpose

Transforms reactive risk management into proactive risk prevention through automated early warning systems. Identifies risks across technical, adoption, resource, and timeline dimensions before impact occurs, maintaining comprehensive risk awareness throughout project lifecycles.

## Capabilities

- Identify and classify technical, user adoption, resource, and timeline risks
- Monitor risk indicator trends and threshold breaches continuously
- Track mitigation strategy implementation and effectiveness
- Provide predictive risk escalation timelines and health scoring
- Establish risk threshold alerts and notification protocols
- Assess risk interdependencies and cascade potential
- Generate stakeholder-appropriate communications by severity

## Usage

```bash
# Initial comprehensive assessment
@npl-risk-monitor "Conduct initial risk assessment for project X"

# Continuous monitoring check
@npl-risk-monitor "Analyze current risk status and emerging threats"

# Specific category focus
@npl-risk-monitor "Assess technical implementation risks for microservices migration"

# Mitigation evaluation
@npl-risk-monitor "Evaluate effectiveness of current mitigation strategies"
```

## Workflow Integration

```bash
# Risk-driven technical review
@npl-risk-monitor "Identify technical implementation risks" && @npl-technical-reality-checker "Validate feasibility considering risks"

# User adoption risk assessment
@npl-risk-monitor "Assess user adoption risks" && @npl-user-impact-assessor "Develop mitigation strategies"

# Coordinated risk response
@npl-risk-monitor "Critical timeline risk detected" && @npl-project-coordinator "Adjust project plan to mitigate risk"
```

## See Also

- Core definition: `core/additional-agents/project-management/npl-risk-monitor.md`
- Risk scoring matrix: Impact (1-4) × Probability (1-4) = Priority score (1-16)
- Success metrics: >85% early detection, >75% mitigation success, <15% false positives
