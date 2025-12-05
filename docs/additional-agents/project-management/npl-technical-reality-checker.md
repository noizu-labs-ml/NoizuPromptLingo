# npl-technical-reality-checker

Complexity buffer planning specialist that assesses semantic complexity, provides realistic timeline adjustments, and validates technical feasibility for AI/ML projects.

## Purpose

Transforms optimistic project planning into realistic, achievable timelines through multi-dimensional complexity analysis and evidence-based timeline adjustment. Identifies hidden technical complexity before it impacts delivery and applies complexity-based buffer calculations for realistic planning.

## Capabilities

- Analyze prompt engineering and cognitive load complexity
- Apply complexity-based buffer calculations (1.0x to 4.0x multipliers)
- Validate proposed technical approaches against constraints
- Identify hidden technical debt and maintenance costs
- Account for learning curve and skill acquisition time
- Assess technology stack compatibility and maturity
- Calculate realistic estimates with 25% to 200% buffers

## Usage

```bash
# Initial project assessment
@npl-technical-reality-checker "Assess complexity for authentication system redesign"

# Mid-project reality check
@npl-technical-reality-checker "Evaluate progress and adjust remaining timeline"

# Scope change impact
@npl-technical-reality-checker "Analyze impact of adding real-time notification feature"

# Technology validation
@npl-technical-reality-checker "Validate feasibility of serverless architecture migration"
```

## Workflow Integration

```bash
# Technical approach validation
@npl-thinker "Design technical approach for feature X" && @npl-technical-reality-checker "Validate approach feasibility and timeline"

# Risk management integration
@npl-technical-reality-checker "Identify technical risks" && @npl-risk-monitor "Create risk mitigation plan" && @npl-project-coordinator "Adjust timeline"

# Complexity-aware planning
@npl-technical-reality-checker "Assess sprint complexity" && @npl-project-coordinator "Plan sprint considering buffers"
```

## See Also

- Core definition: `core/additional-agents/project-management/npl-technical-reality-checker.md`
- Complexity levels: Simple (1.0x), Moderate (1.5x), Complex (2.5x), Experimental (4.0x)
- Success metrics: >85% estimation accuracy, >90% complexity discovery, 70-85% buffer utilization
