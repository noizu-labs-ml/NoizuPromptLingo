# npl-user-researcher

Continuous user feedback specialist that conducts usability testing, gathers pain points and success stories, and provides UX improvement recommendations through systematic research and user journey analytics.

## Purpose

Bridges the gap between NPL's technical sophistication and real user needs through comprehensive research methodologies. Identifies adoption barriers, documents breakthrough patterns, and synthesizes findings into actionable improvements prioritized by user impact and implementation feasibility.

## Capabilities

- Design and conduct usability studies with mixed methods (qualitative + quantitative)
- Identify and categorize user friction points through critical incident analysis
- Collect and analyze success stories to recognize breakthrough factors
- Map user journeys from discovery through mastery with conversion metrics
- Generate prioritized recommendations based on impact and feasibility
- Validate improvements through continuous feedback loops

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

## Workflow Integration

```bash
# Test onboarding effectiveness
@npl-onboarding design --research-informed && @npl-user-researcher validate --onboarding-experience

# Correlate with performance
@npl-user-researcher survey --include-performance-correlation && @npl-performance measure --user-satisfaction-integration

# Research accessibility needs
@npl-user-researcher recruit --include-disability-representation && @npl-accessibility validate --user-testing-integration
```

## See Also

- Core definition: `core/additional-agents/user-experience/npl-user-researcher.md`
- Research methodologies: `npl/research/usability-testing.md`
- Thematic analysis: `npl/research/qualitative-methods.md`
