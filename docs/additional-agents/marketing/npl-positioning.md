# npl-positioning

Developer messaging specialist that transforms technical features into compelling developer benefits, creates A/B testable positioning strategies, and bridges the gap between technical sophistication and immediate practical value.

## Purpose

Converts technical features into developer-relevant outcomes with quantified impact. Creates data-driven positioning strategies to achieve industry-standard 8%+ conversion rates by answering "What's in it for me?" within 5 seconds.

## Capabilities

- Convert technical features into quantified developer benefits
- Generate A/B testable messaging variations for optimization
- Create benefits-first positioning with concrete time savings
- Address developer psychology and decision-making patterns
- Transform research advantages into accessible competitive moats
- Build value proposition matrices for different segments
- Design progressive disclosure of technical depth
- Provide before/after scenarios with measurable results

See [Capabilities](./npl-positioning.detailed.md#capabilities) for complete details.

## Usage

```bash
# Analyze feature positioning opportunities
@npl-positioning analyze feature="cognitive-workflows" --target="senior-engineers"

# Generate A/B test variants
@npl-positioning generate variants --feature="npl-code-reviewer" --angles="time,quality,team"

# Transform technical docs to benefits-first
@npl-positioning convert technical-spec.md --benefits-first --quantified-value
```

See [Usage Reference](./npl-positioning.detailed.md#usage-reference) for all commands.

## Workflow Integration

```bash
# Complete positioning-to-copy workflow
@npl-positioning define value-props > positioning.md && @npl-marketing-copy create landing-page.md --positioning.md

# A/B testing pipeline
@npl-positioning generate variants --count=3 > variants.md && @npl-conversion deploy a-b-test --variants.md

# Community validation
@npl-positioning create message-tests > messages.md && @npl-community validate messages.md --developer-feedback
```

See [Integration Patterns](./npl-positioning.detailed.md#integration-patterns) for complete workflow examples.

## Key Resources

| Topic | Reference |
|-------|-----------|
| Positioning framework | [Positioning Framework](./npl-positioning.detailed.md#positioning-framework) |
| Message transformation | [Message Transformation](./npl-positioning.detailed.md#message-transformation) |
| A/B testing setup | [A/B Testing Framework](./npl-positioning.detailed.md#ab-testing-framework) |
| NPL pump integration | [NPL Pump Integration](./npl-positioning.detailed.md#npl-pump-integration) |
| Success metrics | [Success Metrics](./npl-positioning.detailed.md#success-metrics) |
| Anti-patterns | [Anti-Patterns](./npl-positioning.detailed.md#anti-patterns) |
| Limitations | [Limitations](./npl-positioning.detailed.md#limitations) |

## See Also

- Detailed reference: [npl-positioning.detailed.md](./npl-positioning.detailed.md)
- Core definition: `core/additional-agents/marketing/npl-positioning.md`
- Related agents: [npl-marketing-copy](./npl-marketing-copy.md), [npl-conversion](./npl-conversion.md), [npl-community](./npl-community.md)
