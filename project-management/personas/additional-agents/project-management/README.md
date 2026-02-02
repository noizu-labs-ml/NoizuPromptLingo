# Project Management Agents

Agents responsible for project coordination, risk management, feasibility assessment, and user impact analysis.

## Agents

### npl-project-coordinator
Manages sprint planning, stakeholder coordination, timeline tracking, and cross-team communication. Ensures smooth project execution and stakeholder alignment.

### npl-risk-monitor
Identifies, tracks, and mitigates multi-dimensional risks (technical, adoption, resource, timeline). Maintains risk registers and escalation paths.

### npl-technical-reality-checker
Validates technical feasibility, estimation accuracy, and architectural soundness. Challenges assumptions and provides implementation reality checks.

### npl-user-impact-assessor
Evaluates features from user perspective, prioritizes based on user value, and assesses adoption barriers. Ensures user-centric decision making.

## Workflows

**Sprint Planning & Risk Assessment**
1. npl-project-coordinator: Define sprint scope and timeline
2. npl-technical-reality-checker: Validate feasibility and estimates
3. npl-risk-monitor: Identify potential blockers and risks
4. npl-user-impact-assessor: Confirm user value and prioritize
5. Finalize sprint with mitigations in place

**Feature Prioritization**
1. npl-user-impact-assessor: Assess user impact and value
2. npl-technical-reality-checker: Evaluate effort and dependencies
3. npl-risk-monitor: Flag adoption/execution risks
4. npl-project-coordinator: Sequence and schedule
5. npl-user-impact-assessor: Re-validate prioritization

## Integration Points

- **Upstream**: prd-editor (feature specs), npl-thinker (strategy)
- **Downstream**: tdd-coder (implementation), npl-qa agents (validation)
- **Cross-functional**: npl-positioning (go-to-market), npl-onboarding (rollout)

## Key Responsibilities

| Agent | Primary | Secondary |
|-------|---------|-----------|
| **project-coordinator** | Timeline, stakeholder sync, sprint flow | Dependency mgmt, communication |
| **risk-monitor** | Risk identification, tracking, mitigation | Risk scoring, escalation paths |
| **technical-reality-checker** | Feasibility, estimation, architecture | Tech debt, dependency analysis |
| **user-impact-assessor** | User value assessment, prioritization | Adoption barriers, rollout strategy |
