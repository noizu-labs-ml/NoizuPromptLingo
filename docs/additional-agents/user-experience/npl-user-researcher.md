# npl-user-researcher

Continuous user feedback specialist that conducts usability testing, gathers pain points and success stories, and provides UX improvement recommendations through systematic research and user journey analytics.

## Purpose

Bridges NPL's technical sophistication and real user needs through comprehensive research methodologies. Identifies adoption barriers, documents breakthrough patterns, and synthesizes findings into actionable improvements prioritized by user impact and implementation feasibility.

See [Core Mission](./npl-user-researcher.detailed.md#core-mission) for details.

## Capabilities

- Design and conduct usability studies with mixed methods (qualitative + quantitative)
- Identify and categorize user friction points through critical incident analysis
- Collect and analyze success stories to recognize breakthrough factors
- Map user journeys from discovery through mastery with conversion metrics
- Generate prioritized recommendations based on impact and feasibility
- Validate improvements through continuous feedback loops

See [Primary Functions](./npl-user-researcher.detailed.md#primary-functions) for complete details.

## Usage

```bash
# Conduct comprehensive usability study
@npl-user-researcher study --type="usability" --participants=20 --duration="4weeks" --methods="mixed"

# Analyze pain points
@npl-user-researcher analyze --focus="barriers" --data-source="support-tickets,user-interviews" --segment="new-users"

# Identify success patterns
@npl-user-researcher patterns --type="success-stories" --timeframe="last-6months" --validation="performance-data"

# Map user journey
@npl-user-researcher journey --phase="onboarding" --touchpoints="discovery,first-use,integration" --metrics="conversion,satisfaction"
```

See [Usage Examples](./npl-user-researcher.detailed.md#usage-examples) for more commands.

## Research Methods

The agent supports multiple research methodologies:

| Method | Use Case |
|:-------|:---------|
| Usability Testing | Identify friction points in workflows |
| Critical Incident Analysis | Categorize barriers by type |
| User Journey Mapping | Track conversion between phases |
| Success Story Collection | Document breakthrough patterns |
| Thematic Analysis | Extract patterns from qualitative data |

See [Research Methodologies](./npl-user-researcher.detailed.md#research-methodologies) for protocols and [Data Collection and Analysis](./npl-user-researcher.detailed.md#data-collection-and-analysis) for analysis frameworks.

## Workflow Integration

```bash
# Test onboarding effectiveness
@npl-onboarding design --research-informed && @npl-user-researcher validate --onboarding-experience

# Correlate with performance
@npl-user-researcher survey --include-performance-correlation && @npl-performance measure --user-satisfaction-integration

# Research accessibility needs
@npl-user-researcher recruit --include-disability-representation && @npl-accessibility validate --user-testing-integration
```

See [Agent Integration](./npl-user-researcher.detailed.md#agent-integration) for more patterns.

## Configuration

| Category | Key Parameters |
|:---------|:---------------|
| Research Scope | `--participant-count`, `--study-duration`, `--user-segments` |
| Data Collection | `--analytics-integration`, `--interview-depth`, `--survey-frequency` |
| Analysis | `--statistical-confidence`, `--bias-controls`, `--validation-methods` |
| Ethics | `--anonymization-level`, `--consent-requirements`, `--opt-out-procedures` |

See [Configuration Options](./npl-user-researcher.detailed.md#configuration-options) for complete parameter reference.

## Best Practices

1. Start with user needs, not technical capabilities
2. Combine quantitative data with qualitative insights
3. Make research ongoing, not one-time events
4. Include diverse user perspectives in sampling
5. Test whether improvements solve identified problems

See [Best Practices](./npl-user-researcher.detailed.md#best-practices) for complete guidelines.

## See Also

- **Detailed Reference**: [npl-user-researcher.detailed.md](./npl-user-researcher.detailed.md)
- **Core definition**: `core/additional-agents/user-experience/npl-user-researcher.md`
- **Related agents**: [npl-onboarding](./npl-onboarding.md), [npl-accessibility](./npl-accessibility.md), [npl-performance](./npl-performance.md)
